//! Minimal axum service: health check + an in-memory items resource.
//! Run: `cargo run` → http://127.0.0.1:3000/health

use std::{
    collections::HashMap,
    sync::{Arc, RwLock},
};

use axum::{
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::get,
};
use serde::{Deserialize, Serialize};

#[derive(Clone, Default)]
struct AppState {
    items: Arc<RwLock<HashMap<u64, Item>>>,
    next_id: Arc<RwLock<u64>>,
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
struct Item {
    id: u64,
    name: String,
}

#[derive(Deserialize)]
struct NewItem {
    name: String,
}

#[derive(Debug, thiserror::Error)]
enum ApiError {
    #[error("item {0} not found")]
    NotFound(u64),
    #[error("name must not be empty")]
    EmptyName,
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        let status = match self {
            ApiError::NotFound(_) => StatusCode::NOT_FOUND,
            ApiError::EmptyName => StatusCode::UNPROCESSABLE_ENTITY,
        };
        (
            status,
            Json(serde_json::json!({ "error": self.to_string() })),
        )
            .into_response()
    }
}

async fn health() -> Json<serde_json::Value> {
    Json(serde_json::json!({ "status": "ok" }))
}

async fn list_items(State(state): State<AppState>) -> Json<Vec<Item>> {
    let items = state.items.read().expect("lock poisoned");
    let mut all: Vec<Item> = items.values().cloned().collect();
    all.sort_by_key(|i| i.id);
    Json(all)
}

async fn create_item(
    State(state): State<AppState>,
    Json(body): Json<NewItem>,
) -> Result<(StatusCode, Json<Item>), ApiError> {
    let name = body.name.trim();
    if name.is_empty() {
        return Err(ApiError::EmptyName);
    }
    let id = {
        let mut next = state.next_id.write().expect("lock poisoned");
        *next += 1;
        *next
    };
    let item = Item {
        id,
        name: name.to_string(),
    };
    state
        .items
        .write()
        .expect("lock poisoned")
        .insert(id, item.clone());
    Ok((StatusCode::CREATED, Json(item)))
}

async fn get_item(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<Item>, ApiError> {
    state
        .items
        .read()
        .expect("lock poisoned")
        .get(&id)
        .cloned()
        .map(Json)
        .ok_or(ApiError::NotFound(id))
}

fn app(state: AppState) -> Router {
    Router::new()
        .route("/health", get(health))
        .route("/api/items", get(list_items).post(create_item))
        .route("/api/items/{id}", get(get_item))
        .with_state(state)
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()),
        )
        .init();

    let addr = std::env::var("ADDR").unwrap_or_else(|_| "127.0.0.1:3000".into());
    let listener = tokio::net::TcpListener::bind(&addr).await?;
    tracing::info!("listening on http://{addr}");
    axum::serve(listener, app(AppState::default())).await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::Request;
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    async fn send(app: Router, req: Request<Body>) -> (StatusCode, serde_json::Value) {
        let res = app.oneshot(req).await.unwrap();
        let status = res.status();
        let bytes = res.into_body().collect().await.unwrap().to_bytes();
        (status, serde_json::from_slice(&bytes).unwrap())
    }

    #[tokio::test]
    async fn health_ok() {
        let req = Request::get("/health").body(Body::empty()).unwrap();
        let (status, body) = send(app(AppState::default()), req).await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(body["status"], "ok");
    }

    #[tokio::test]
    async fn create_then_get() {
        let state = AppState::default();
        let req = Request::post("/api/items")
            .header("content-type", "application/json")
            .body(Body::from(r#"{"name":"widget"}"#))
            .unwrap();
        let (status, body) = send(app(state.clone()), req).await;
        assert_eq!(status, StatusCode::CREATED);
        assert_eq!(body["id"], 1);

        let req = Request::get("/api/items/1").body(Body::empty()).unwrap();
        let (status, body) = send(app(state), req).await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(body["name"], "widget");
    }

    #[tokio::test]
    async fn rejects_empty_name_and_missing_item() {
        let req = Request::post("/api/items")
            .header("content-type", "application/json")
            .body(Body::from(r#"{"name":"  "}"#))
            .unwrap();
        let (status, _) = send(app(AppState::default()), req).await;
        assert_eq!(status, StatusCode::UNPROCESSABLE_ENTITY);

        let req = Request::get("/api/items/42").body(Body::empty()).unwrap();
        let (status, body) = send(app(AppState::default()), req).await;
        assert_eq!(status, StatusCode::NOT_FOUND);
        assert_eq!(body["error"], "item 42 not found");
    }
}

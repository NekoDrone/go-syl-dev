import envoy
import gleam/dynamic
import gleam/list
import gleam/pgo
import gleam/result
import json_helper

pub fn setup_db() -> pgo.Connection {
  let assert Ok(db) = open_db_connection()
  let assert Ok(_) = create_db(db)
  db
}

fn open_db_connection() -> Result(pgo.Connection, Nil) {
  use db_url <- result.try(envoy.get("DATABASE_URL"))
  use config <- result.try(pgo.url_config(db_url))
  Ok(pgo.connect(config))
}

fn create_db(db: pgo.Connection) -> Result(_, pgo.QueryError) {
  let query =
    "
    CREATE TABLE IF NOT EXISTS urls (
      id SERIAL PRIMARY KEY,
      short TEXT UNIQUE NOT NULL,
      target TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    "

  pgo.execute(query, db, [], dynamic.dynamic)
}

pub fn find_target_from_short(
  db: pgo.Connection,
  short: String,
) -> Result(String, Nil) {
  let query = "
    SELECT target
    FROM public.urls
    WHERE short = '" <> short <> "'
    ORDER BY short
    LIMIT 1;
    "

  let return_type = dynamic.element(0, dynamic.string)

  let assert Ok(response) = pgo.execute(query, db, [], return_type)

  response.rows
  |> list.first
}

pub fn add_redirect_to_db(
  url_info: json_helper.AddUrlInfo,
  db: pgo.Connection,
) -> Result(_, pgo.QueryError) {
  let query = "
    INSERT INTO urls (short, target)
    VALUES('" <> url_info.short_url <> "','" <> url_info.target_url <> "')
    ON CONFLICT (short)
    DO UPDATE SET
      target = EXCLUDED.target
    "
  pgo.execute(query, db, [], dynamic.dynamic)
}

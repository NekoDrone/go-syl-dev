import env
import gleam/bit_array
import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/list
import gleam/pgo
import gleam/result
import json_helper
import mist
import postgres

pub fn main() {
  env.env_config()
  let db = postgres.setup_db()

  let assert Ok(_) =
    fn(req: Request(mist.Connection)) -> Response(mist.ResponseData) {
      case request.path_segments(req) {
        ["api", "add_url"] -> add_url_record(req, db)
        _ -> redirect_url(req, db)
      }
    }
    |> mist.new
    |> mist.port(8080)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}

fn redirect_url(
  request: Request(mist.Connection),
  db: pgo.Connection,
) -> Response(mist.ResponseData) {
  let short_url =
    request
    |> request.path_segments
    |> list.first
    |> result.unwrap("nil")

  let target_url =
    postgres.find_target_from_short(db, short_url)
    |> result.unwrap("")

  case target_url {
    "" ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_builder.new()))
    _ ->
      response.new(301)
      |> response.prepend_header("location", target_url)
      |> response.set_body(
        mist.Bytes(bytes_builder.from_string(
          "You are being redirected to " <> target_url,
        )),
      )
  }
}

fn add_url_record(
  request: Request(mist.Connection),
  db: pgo.Connection,
) -> Response(mist.ResponseData) {
  request
  |> mist.read_body(1024 * 1024 * 10)
  |> result.map(fn(req) {
    let user_info =
      bit_array.to_string(req.body)
      |> result.unwrap("")
      |> json_helper.url_info_from_json
    case postgres.add_redirect_to_db(user_info, db) {
      Ok(_) -> {
        response.new(200)
        |> response.set_body(mist.Bytes(bytes_builder.new()))
      }
      Error(err) -> {
        io.debug(err)
        response.new(400)
        |> response.set_body(mist.Bytes(bytes_builder.new()))
      }
    }
  })
  |> result.lazy_unwrap(fn() {
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_builder.new()))
  })
}

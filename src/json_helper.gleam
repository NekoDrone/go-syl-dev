import gleam/dynamic
import gleam/json
import gleam/result

pub type AddUrlInfo {
  AddUrlInfo(short_url: String, target_url: String)
}

pub fn url_info_from_json(json_string: String) -> AddUrlInfo {
  let url_info_decoder =
    dynamic.decode2(
      AddUrlInfo,
      dynamic.field("short_url", of: dynamic.string),
      dynamic.field("target_url", of: dynamic.string),
    )

  json.decode(json_string, url_info_decoder)
  |> result.unwrap(AddUrlInfo("", ""))
}

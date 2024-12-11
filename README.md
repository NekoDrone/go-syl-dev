# go.syl.dev

A simple URL shortener akin to [go.gov.sg](https://go.gov.sg/) written in [Gleam](https://gleam.run/)!

## Usage

You may visit [go.sylfr.dev/dashboard](https://go.sylfr.dev/dashboard) to see the frontend, but you will not be able to access it as this is meant for personal use.

If you would like to use this project for yourself, please fork this project and self-host the image anywhere Gleam/BEAM/Erlang will run.

If you intend on hosting on Fly, please ensure that your `fly.toml` file is re-generated using the CLI, or it will not deploy as you will not have the appropriate deploy token for the project.

## Contributing

If there are any issues, please feel free to open a pull request or file an issue under the Issues tab. Both PRs and Issues are welcome wherever 😊

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
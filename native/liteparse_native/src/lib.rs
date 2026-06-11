use std::sync::OnceLock;

use rustler::NifMap;
use tokio::runtime::Runtime;

use liteparse::{LiteParse, LiteParseConfig};

#[derive(NifMap)]
pub struct ParseResponse {
    pub text: String,
    pub page_count: usize,
}

fn runtime() -> &'static Runtime {
    static RT: OnceLock<Runtime> = OnceLock::new();
    RT.get_or_init(|| Runtime::new().expect("failed to build tokio runtime"))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_path(path: String) -> Result<ParseResponse, String> {
    let config = LiteParseConfig {
        quiet: true,
        ..LiteParseConfig::default()
    };
    let parser = LiteParse::new(config);
    let result = runtime()
        .block_on(parser.parse(&path))
        .map_err(|e| e.to_string())?;
    Ok(ParseResponse {
        text: result.text,
        page_count: result.pages.len(),
    })
}

rustler::init!("Elixir.LiteParse.Native");

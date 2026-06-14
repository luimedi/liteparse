use std::sync::OnceLock;

use rustler::{Binary, NifMap};
use tokio::runtime::Runtime;

use liteparse::types::PdfInput;
use liteparse::{LiteParse, LiteParseConfig, OutputFormat};

#[derive(NifMap)]
pub struct ParseOpts {
    pub ocr_language: String,
    pub ocr_enabled: bool,
    pub ocr_server_url: Option<String>,
    pub tessdata_path: Option<String>,
    pub max_pages: usize,
    pub target_pages: Option<String>,
    pub dpi: f64,
    pub output_format: String,
    pub preserve_very_small_text: bool,
    pub password: Option<String>,
    pub quiet: bool,
    pub num_workers: usize,
}

impl From<ParseOpts> for LiteParseConfig {
    fn from(opts: ParseOpts) -> Self {
        LiteParseConfig {
            ocr_language: opts.ocr_language,
            ocr_enabled: opts.ocr_enabled,
            ocr_server_url: opts.ocr_server_url,
            tessdata_path: opts.tessdata_path,
            max_pages: opts.max_pages,
            target_pages: opts.target_pages,
            dpi: opts.dpi as f32,
            output_format: match opts.output_format.as_str() {
                "text" => OutputFormat::Text,
                _ => OutputFormat::Json,
            },
            preserve_very_small_text: opts.preserve_very_small_text,
            password: opts.password,
            quiet: opts.quiet,
            num_workers: opts.num_workers,
        }
    }
}

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
fn parse(path: String, opts: ParseOpts) -> Result<ParseResponse, String> {
    let parser = LiteParse::new(LiteParseConfig::from(opts));

    let result = runtime()
        .block_on(parser.parse(&path))
        .map_err(|e| e.to_string())?;

    Ok(ParseResponse {
        text: result.text,
        page_count: result.pages.len(),
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_input(bytes: Binary, opts: ParseOpts) -> Result<ParseResponse, String> {
    let parser = LiteParse::new(LiteParseConfig::from(opts));

    let result = runtime()
        .block_on(parser.parse_input(PdfInput::Bytes(bytes.to_vec())))
        .map_err(|e| e.to_string())?;

    Ok(ParseResponse {
        text: result.text,
        page_count: result.pages.len(),
    })
}

rustler::init!("Elixir.LiteParse.Native");

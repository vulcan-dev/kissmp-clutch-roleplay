use serde::{Serialize,Deserialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Client {
    pub name: Option<String>,
    pub secret: Option<String>
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Executor {
    pub name: Option<String>,
    pub secret: Option<String>
}

#[derive(Default, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Commands {
    pub client: Option<Client>,
    pub executor: Option<Executor>,
    #[serde(rename="type")]
    pub command: String,

    pub time_str: Option<String>,
    pub data: Option<String>,
    pub reason: Option<String>
}
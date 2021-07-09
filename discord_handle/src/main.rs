#[macro_use] extern crate log;
use webhook::Webhook;
use tokio::process;
use std::{process::{Stdio}};
use tokio::io::{BufReader, AsyncBufReadExt, AsyncWriteExt};
use regex::Regex;
use pretty_env_logger;
use std::error::Error;
use chrono::offset::Local;

mod structs;
use structs::Commands;

struct Webhooks {
    join: Webhook,
    vehicle: Webhook,
    chat: Webhook,
    moderation: Webhook,
}

fn setup_webhooks() -> Webhooks {
    let p = Webhook::from_url;

    Webhooks {
        join: p("https://discord.com/api/webhooks/862747269722800188/5Q1JIPOmFWEYU420QM2CQiR7UtdbKly1iYiC5kA7JrTWOwHq0QFNWjSIKtzfrWXWFwoo"),
        vehicle: p("https://discord.com/api/webhooks/862795025687380028/xrQrsS_hjTWqR_dwrmFSGJPedeQzdWytZqCsq4rHcSFvqJf2VjvmQ9HW1i6es6Oht5KB"),
        chat: p("https://discord.com/api/webhooks/862748518557286401/t2oAUupmhMb8XmEfqR8hQSe9pKrOQvhS_NvDCArDfBGP2tmv_egqeTIWpTq5YBI6fx5X"),
        moderation: p("https://discord.com/api/webhooks/862749070937686046/STAMzUzUJNMNTkC9O0BLt-n0ot7-M9xcFoeq-phc_msnzj6AFWQ0-0lRZbrkYHGxiMca"),
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error + 'static>> {
    pretty_env_logger::init();
    let webhooks = setup_webhooks();
    let mut clutchrp = process::Command::new("./clutch-roleplay.exe")
        .stdout(Stdio::piped())
        .stdin(Stdio::piped())
        .spawn()
        .expect("Failed processing command");

    let stdout = clutchrp.stdout.take().expect("Failed to open stdout");
    let mut stdin = clutchrp.stdin.take().expect("Failed to open stdin");
    let mut server_r = BufReader::new(stdout).lines();
    
    /* Input */
    tokio::spawn(async move {        
        loop {
            let mut line = String::new();
            std::io::stdin().read_line(&mut line).expect("Failed to read line");
            stdin.write_all(line.as_bytes()).await.expect("Failed writing");
            //stdin.flush().await.expect("Failed flushing");
        }
    });

    let api_regex = Regex::new(r"^\[API\]:\s*(\{.*\})").expect("Bad Regex");
    let debug_regex = Regex::new(r".*\[DEBUG\]: (.*)").expect("Bad Regex");
    let info_regex = Regex::new(r".*\[INFO\]: (.*)").expect("Bad Regex");
    let error_regex = Regex::new(r".*\[ERROR\]: (.*)").expect("Bad Regex");
    let warning_regex = Regex::new(r".*\[WARN\]: (.*)").expect("Bad Regex");
    let fatal_regex = Regex::new(r".*\[FATAL\]: (.*)").expect("Bad Regex");

    /* Output */
    while let Some(line) = server_r.next_line().await? {
        if let Some(data) = api_regex.captures(&line) {
            let cmd: Commands = serde_json::from_str(&data[1])?;
            if let Err(e) = command_handler(cmd, &webhooks).await {
                warn!("Failed to handle message: {:#?}", e);
            }

        } else if let Some(cap) = debug_regex.captures(&line) {
            debug!  ("Server: {}", &cap[1])
        } else if let Some(cap) = info_regex.captures(&line) {
            info!   ("Server: {}", &cap[1])
        } else if let Some(cap) = error_regex.captures(&line) {
            error!  ("Server: {}", &cap[1])
        } else if let Some(cap) = warning_regex.captures(&line) {
            warn!   ("Server: {}", &cap[1])
        } else if let Some(cap) = fatal_regex.captures(&line) {
            error!  ("Fatal: {}", &cap[1]);
            break
        } else {
            info!   ("Server: {}", &line)
        }
    }

    Ok(())
}

async fn command_handler(cmd: Commands, webhooks: &Webhooks) -> Result<(), Box<dyn Error>> {
    let cname = cmd.client.as_ref().unwrap().name.as_ref().unwrap();
    let data = format!(r"{}", cmd.data.as_ref().unwrap());
    match cmd.command.as_str() {
        "user_join_leave" => {
            webhooks.join.send(move |m| {
                let message = format!(
                    "> {} has **{}**",
                    cname,
                    data
                );
                m.content(message.as_str())
            }).await.unwrap_or_else(|e|{
                error!("Failed sending {}", e)
            })
        },
        "mod_log" => {
            let ename = cmd.executor.as_ref().unwrap().name.as_ref().unwrap();
            let reason = cmd.reason.as_deref().unwrap();
            match data.as_str() {
                "kicked" => {
                    webhooks.moderation.send(move |m| m
                        .embed(|e| e
                            .title(&data)
                            .color(0xB8323B)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .field("Reason", reason, false)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                },
                "banned" => {
                    let unban_date = cmd.time_str.as_ref().unwrap().as_str();
                    webhooks.moderation.send(move |m| m.
                        embed(|e| e
                            .title(&data)
                            .color(0xB8323B)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .field("UnbanDate"  , unban_date, false)
                            .field("Reason", reason, false)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                },
                "unbanned" => {
                    webhooks.moderation.send(move |m| m.
                        embed(|e| e
                            .title(&data)
                            .color(0x26BD9C)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                },
                "muted" => {
                    let unmute_date = cmd.time_str.as_ref().unwrap().as_str();
                    webhooks.moderation.send(move |m| m.
                        embed(|e| e
                            .title(&data)
                            .color(0xB8323B)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .field("UnmuteDate"  , unmute_date, false)
                            .field("Reason", reason, false)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                },
                "unmuted" => {
                    webhooks.moderation.send(move |m| m.
                        embed(|e| e
                            .title(&data)
                            .color(0x26BD9C)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                },
                "warn" => {
                    
                    webhooks.moderation.send(move |m| m.
                        embed(|e| e
                            .title(&data)
                            .color(0xB8323B)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .field("Reason", reason, false)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                },
                "remove_warn" => {
                    webhooks.moderation.send(move |m| m.
                        embed(|e| e
                            .title(&data)
                            .color(0x26BD9C)
                            .field("Executor"   , ename, true)
                            .field("Client"     , cname, true)
                            .timestamp(format!("{}", Local::now().to_rfc3339()).as_str())
                        )
                    ).await.unwrap_or_else(|e|{
                        error!("Failed sending {}", e)
                    })
                }
                _ => warn!("Command not understood: {:?}", cmd)
            }
        },
        "vehicle_log" => {
            webhooks.vehicle.send(move |m| {
                let message = format!(
                    "> {} has **{}**",
                    cname,
                    data
                );
                m.content(message.as_str())
            }).await.unwrap_or_else(|e|{
                error!("Failed sending {}", e)
            })
        },
        "user_message" => {
            webhooks.chat.send(move |m| {
                m.username(&cname)
                .content(&data)
            }).await.unwrap_or_else(|e|{
                error!("Failed sending {}", e)
            })
        },
        _ => warn!("Command not understood: {:?}", cmd)
    }

    Ok(())
}
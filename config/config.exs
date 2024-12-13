# General application configuration
import Config

config :langchain, openai_key: System.get_env("OPENAI_KEY") || "OPENAI_KEY"
config :langchain, openai_org_id: System.get_env("OPENAI_ORG_ID") || "OPENAI_ORG_ID"

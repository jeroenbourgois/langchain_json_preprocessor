defmodule LangChainJsonProcessor do
  alias LangChain.Function
  alias LangChain.Message
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Utils.ChainResult
  alias LangChain.MessageProcessors.JsonProcessor

  def run() do
    # map of data we want to be passed as `context` to the function when
    # executed.
    custom_context = %{
      "user_id" => 123,
      "hairbrush" => "drawer",
      "dog" => "backyard",
      "sandwich" => "kitchen"
    }

    # a custom Elixir function made available to the LLM
    custom_fn =
      Function.new!(%{
        name: "custom",
        description: "Returns the location of the requested element or item.",
        parameters_schema: %{
          type: "object",
          properties: %{
            thing: %{
              type: "string",
              description: "The thing whose location is being requested."
            }
          },
          required: ["thing"]
        },
        function: fn %{"thing" => thing} = _arguments, context ->
          # our context is a pretend item/location location map
          {:ok, context[thing]}
        end
      })

    # create and run the chain
    {:ok, updated_chain, _msg} =
      LLMChain.new!(%{
        llm:
          ChatOpenAI.new!(%{
            "model" => "gpt-4o-mini",
            "top_p" => 1,
            "messages" => [],
            "temperature" => 0.4,
            "response_format" => %{
              "type" => "json_object"
            },
            "presence_penalty" => 0,
            "frequency_penalty" => 0
          }),
        custom_context: custom_context,
        verbose: true
      })
      |> LLMChain.add_messages([
        Message.new_system!("You are a helpfull assistant."),
        Message.new_user!("Where is the hairbrush located? Please return JSON.")
      ])
      |> LLMChain.add_tools(custom_fn)
      |> LLMChain.message_processors([JsonProcessor.new!(~r/```json(.*?)```/s)])
      |> LLMChain.run(mode: :while_needs_response)

    # print the LLM's answer
    IO.inspect(ChainResult.to_string(updated_chain))
    # => "The hairbrush is located in the drawer."
  end
end

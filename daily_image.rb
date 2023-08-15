start = Time.now

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "dotenv", "~> 2.8.1"
  gem "midjourney", "~> 0.1.0"
  gem "ruby-openai", "~> 5.0.0"
end

require "dotenv/load"
require "midjourney"
require "openai"

openai = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
openai_prompt = "Generate a prompt for an AI called Midjourney that generates images using AI. The image will be posted on X each day. The purpose of the image is to grab attention and drive follows and engagement. Choose a random theme for the image to be based around."
openai_response = openai.chat(
  parameters: {
      model: "gpt-4",
      messages: [{ role: "user", content: openai_prompt}]
  })
midjourney_prompt = openai_response.dig("choices", 0, "message", "content")

puts midjourney_prompt

midjourney = Midjourney::Client.new(access_token: ENV["MIDJOURNEY_API_KEY"])
midjourney_response = midjourney.imagine(parameters: {prompt: midjourney_prompt })
midjourney_task_id = midjourney_response["taskId"]

until (midjourney_result = midjourney.result(parameters: {taskId: midjourney_task_id})).has_key?("imageURL")
  if midjourney_result.has_key?("percentage")
    puts "#{midjourney_result["percentage"]}% done"
  elsif midjourney_result.has_key?("status")
    puts "#{midjourney_result["status"]}"
  end
  sleep(2)
end

puts "Image generated: #{midjourney_result["imageURL"]}"

puts "Time taken: #{Time.now - start} seconds"

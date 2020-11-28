using System.Linq;
using System;
using System.Net.Http;
using System.Text.Json;

var apiEndpoint = Environment.GetEnvironmentVariable("AWS_LAMBDA_RUNTIME_API");
var client = new HttpClient();

// http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next
// http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response

while (true) 
{
    var request = await client.GetAsync($"http://{apiEndpoint}/2018-06-01/runtime/invocation/next");
    var requestId = request.Headers.GetValues("Lambda-Runtime-Aws-Request-Id").Single();
    var responseObject = new {success="true"};
    await client.PostAsync(
        $"http://{apiEndpoint}/2018-06-01/runtime/invocation/{requestId}/response", 
        new StringContent(JsonSerializer.Serialize(responseObject)));
}

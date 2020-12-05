using System;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

using Amazon.Lambda.Core;


// using Amazon.Lambda.RuntimeSupport;
// using Amazon.Lambda.Serialization.SystemTextJson;
// await PackageLoop();

// static async Task PackageLoop()
// {
//     using var handlerWrapper = HandlerWrapper.GetHandlerWrapper(
//         (Func<Payload, ILambdaContext, string>)FunctionHandler,
//         new DefaultLambdaJsonSerializer());

//     using var bootstrap = new LambdaBootstrap(handlerWrapper);

//     await bootstrap.RunAsync();
// }

await ManualLoop();

static async Task ManualLoop() 
{
    // http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next
    // http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response
    var apiEndpoint = Environment.GetEnvironmentVariable("AWS_LAMBDA_RUNTIME_API");
    var client = new HttpClient();

    while (true) 
    {
        var request = await client.GetAsync($"http://{apiEndpoint}/2018-06-01/runtime/invocation/next");
        var requestId = request.Headers.GetValues("Lambda-Runtime-Aws-Request-Id").Single();

        var requestBody = await request.Content.ReadAsStringAsync();
        var payload = JsonSerializer.Deserialize<Payload>(requestBody);
        var response = FunctionHandler(payload, null);

        await client.PostAsync(
            $"http://{apiEndpoint}/2018-06-01/runtime/invocation/{requestId}/response", 
            new StringContent(JsonSerializer.Serialize(response)));
    }
}

/// <summary>
/// A simple function that takes a string and does a ToUpper
/// </summary>
/// <param name="input"></param>
/// <param name="context"></param>
/// <returns></returns>
static string FunctionHandler(Payload input, ILambdaContext context)
{
    // DoWork();
    return input?.key1?.ToUpper();
}

static int DoWork()
{
    var result = 0;
    
    for (var i = 0; i< 999999999; i++) 

    {
        result += i;
    }
    
    return result;
}

record Payload(string key1, string key2, string key3);

package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;
import java.util.Random;

import software.amazon.awssdk.services.lambda.LambdaClient;
import software.amazon.awssdk.services.lambda.model.GetAccountSettingsResponse;
import software.amazon.awssdk.services.lambda.model.LambdaException;

// Handler value: example.Handler
public class Handler implements RequestHandler<Map<String,String>, String> {

    private static final LambdaClient lambdaClient = LambdaClient.builder().build();
    // unexpected usage, this creates an extra trace during cold start
    GetAccountSettingsResponse unused = lambdaClient.getAccountSettings();

    @Override
    public String handleRequest(Map<String,String> event, Context context) {

        LambdaLogger logger = context.getLogger();
        logger.log("Handler invoked");
        logger.log(event.toString());

        if (event.containsKey("sleepMs")) {
            int sleepMs;
            try {
                sleepMs = Integer.parseInt(event.get("sleepMs"));
            } catch (NumberFormatException e) {
                Random r = new Random();
                sleepMs = r.nextInt(3000);
            }
            logger.log("sleeping " + sleepMs + " milliseconds");
            try {
                Thread.sleep(sleepMs);
            } catch (InterruptedException e) {
                logger.log(e.getMessage());
            }
        }

        if (event.get("exception") != null) {
            // throw a division by zero
            int notUsed = 1/0;
        }

        GetAccountSettingsResponse response = null;
        try {
            response = lambdaClient.getAccountSettings();
        } catch(LambdaException e) {
            logger.log(e.getMessage());
        }
        return response != null ? "Total code size for your account is " + response.accountLimit().totalCodeSize() + " bytes" : "Error";
    }
}

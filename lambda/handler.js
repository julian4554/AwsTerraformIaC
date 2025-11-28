const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient();

exports.handler = async (event) => {
    const id = Date.now().toString();

    const command = new PutItemCommand({
        TableName: "uni-project-table",
        Item: {
            id: { S: id },
            timestamp: { S: new Date().toISOString() }
        }
    });

    await client.send(command);

    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Item stored", id })
    };
};

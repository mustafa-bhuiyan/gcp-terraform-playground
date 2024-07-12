# How to Test Google Storage Even Drive CF Invocation:

Reference: https://cloud.google.com/eventarc/docs/run/create-trigger-storage-gcloud#event-generation

- Check if the eventarc trigger has been create:

    `gcloud eventarc triggers list --location=us-central1`
    
    ```
    NAME                     TYPE                                      DESTINATION                        ACTIVE  LOCATION
        gcf-v2-hellohttp-809756  google.cloud.storage.object.v1.finalized  Cloud Functions: gcf-v2-hellohttp  Yes     us-central1
    ```

## Generate and view an event
1. To generate an event, upload a text file to Cloud Storage:
     
     ```
     echo "Hello World" > random.txt
     gsutil cp random.txt gs://<TRIGGER-BUCKET>/random.txt
     ```
     The upload generates an event and the Cloud Run service logs the event's message.
2. To view the log entry, filter the log entries, and return the output in JSON format:

    ```
    gcloud logging read 'jsonPayload.message: "Received event of type google.cloud.storage.object.v1.finalized."'
    ```
3. Look for a log entry related to the `eventtype: google.cloud.storage.object.v1.finalized`.

Congratulations! You have successfully deployed an event receiver service to Cloud Run, created an Eventarc trigger, generated an event from Cloud Storage, and viewed it in the Cloud Run logs.
Public class uploadPDFToAWScls{
public void uploadPDFToAWS(Blob binaryPdfString, String key, String secret,String fName){

        BigMachineUrls__c AwsUrls= BigMachineUrls__c.getValues('AWS');
        String awsURL = 'https://6n064zp2s6.execute-api.us-west-2.amazonaws.com/prod/';
        String bucketname = 'CustomerStatement';
        if(AwsUrls!=null){awsURL = AwsUrls.Bigmachine_Url__c;
        bucketname = AwsUrls.DefaultUserName__c;
        }
        HttpRequest urlreq = new HttpRequest();
        //urlreq.setEndpoint('https://vsu3i20dqe.execute-api.us-west-2.amazonaws.com/salesforce/'+fName);
        urlreq.setEndpoint(awsURL+''+fName);
        urlreq.setMethod('GET');
        Http httpp = new Http();
        HTTPResponse urlres = new HTTPResponse();
        
        if(!Test.isRunningTest()){
        urlres = httpp.send(urlreq);
        }
            System.debug('RESPONSE STRING: ' + urlres.toString());
            System.debug('RESPONSE STATUS: '+urlres.getbody());
            System.debug('STATUS_CODE: '+urlres.getStatusCode());

        String Dateee = Datetime.now().formatGMT('EEE,   dd MMM yyyy HH:mm:ss z');
        
        String formattedDateString;
        String method = 'PUT';
        String filename = fName+'.pdf';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        //req.setHeader('Host','s3-website-us-west-2.amazonaws.com');
        
        String returnurlresponse = '';
        if(!Test.isRunningTest()){
        returnurlresponse = urlres.getbody();
        }
        req.setEndpoint(returnurlresponse);
                //req.setHeader('Content-Length', string.valueOf(binaryPdfString.length()));
        //req.setHeader('Content-Encoding', 'base64');
        //req.setHeader('X-Amz-Security-Token','FQoDYXdzEH8aDBj8rh6AsplgeSJsSSK8AvjfPbVJXRmU3jMXvDaLFu9k4QTmkWkNLR+Rc79DPPQIJ1j7FwM3aRqPPQUh/3El8bolkQer2Ig4P0VSf4wbEnW5J1p/U1czHNCicigs8TuFKE2fCFM4BMV0XcF6INjGRXFeQqeUTbr4RjmD6wxWEVR9rn1wmjRtskRgV/ojMSVAPEhE61nHRUKPW3z4TDaRrISlGbHAB4hgB/zV6qZwDMFAhQ9LRmEv+cjg1XYJzfeqFpcMiCkpq4pNcljYDiZ2t5eYC8GOKdJNQXO5lr/PqeIxa/RvN3g24v1vyBb72iOorB95NQ2Bwfq2FpCoAGIS1DLz3Trs5/PsJxKjymI6CE7cHAhXy+QdEQVMiYxh3ItzuAW2nQssLsUpSnspHaxzt/ZbM8y/8hntbTMvtSwZ7gNyumoQx2BbqB2YBpEow7LsyQU=');
        req.setTimeout(120000);
        //get signature string
        Blob keye = Blob.valueOf('123456789012345678901234');
        Blob cipherText = Crypto.encryptWithManagedIV('AES192', keye, Blob.valueOf(filename));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        String stringToSign = 'PUT\n\n\n'+formattedDateString+'\n\n/'+bucketname+'/'+filename;
        String signed = createSignature(stringToSign,secret);
        System.debug(signed+'**');

        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        System.debug('HeaderString ** '+authHeader);
        //req.setHeader('Authorization',authHeader);
        //req.setHeader('X-Amz-Credential',authHeader);
        //req.setHeader('Content-Type', 'application/pdf');
        //req.setHeader('Content-Type','text/html');// 'application/pdf');
        //req.setHeader('X-Amz-Date', Dateee);
        //req.setHeader('X-Amz-SignedHeaders','host');
        //req.setHeader('X-Amz-Server-Side-Encryption','SHA256');
        //req.setHeader('X-Amz-Algorithm','AWS4-HMAC-SHA256');

        //Blob PDF = EncodingUtil.base64Decode(binaryPdfString);
        req.setBodyAsBlob(binaryPdfString);
        //system.debug(req.getHeader()+'HH');
        system.debug(req.getBody()+'BB');
        Http http = new Http();

        try {
        System.debug(req.getBody()+'Test');
        HTTPResponse res = new HTTPResponse();
            //Execute web service call
            If(!Test.isrunningTest()){
            res = http.send(req);
            }
            System.debug('RESPONSE STRING: ' + res.toString());
            System.debug('RESPONSE STATUS: '+res.getStatus());
            System.debug('STATUS_CODE: '+res.getStatusCode());

        } catch(System.CalloutException e) {
            system.debug('AWS Service Callout Exception: ' + e.getMessage());
        }

}

public string createSignature(string canonicalBuffer,String secret){
        string sig;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret));
        System.debug('Signature '+mac);
        sig = EncodingUtil.base64Encode(mac);

        return sig;

}
}
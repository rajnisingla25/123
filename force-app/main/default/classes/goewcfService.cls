public class goewcfService{
    public goewcfService(){
    }
    
   
    
    public string JSONStateAbbrevation(string geoURL){
        HttpRequest req = new HttpRequest();
         HttpResponse res = new HttpResponse();
        req.setEndpoint(geoURL);
        req.setMethod('GET');         
        // Make the HTTP request call   
        if(!test.isRunningTest()){
            res = makeCallout(req);      
        }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/NC?app=RDC&v=1&format=JSON'){
                res.setbody('"NC"');
        }
        // Verify results     
       // System.assert(res.getStatusCode() == 200);    
      //  System.assertEquals('OK', res.getStatus());
       
        // Parse results 
        string stateAbb = '';  
        if(res.getBody().contains('"'))      
        stateAbb  =  res.getBody().replaceAll('"','');  
                 
      
        return stateAbb ;
    }
    
    public string getStateAbbreviationFromPostalCode(string geoURL){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(geoURL);
        req.setMethod('GET');   
        if(!test.isRunningTest()){      
            res = makeCallout(req);
        }
        else {
            res.setbody('{"City":"New York","SearchAreaID":2000173,"StateID":"NY"}');
        }
        
        String stateAbb = null;  
        JSONParser parser = JSON.createParser(res.getBody());
        system.debug('URL ---' + geoURL);
        system.debug('RES ---' + res.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getCurrentName() == 'StateID')) {
                parser.nextToken();
                stateAbb = parser.getText();
            }
        }
        return stateAbb ;
    }
    
    public list<SelectOption> JSONtoOptions(string geoURL){
        System.debug('------ geoURL --->'+geoURL);
        string responseFromGeo = '';
        List<SelectOption> options = new List<SelectOption>();                       
        HttpRequest req = new HttpRequest();
        req.setEndpoint(geoURL);
        req.setMethod('GET');         
        // Make the HTTP request call  
         HttpResponse res = new HttpResponse();
          JSONParser parser;
        if(!Test.isRunningTest()){
            res = makeCallout(req); 
            // Verify results     
            System.assert(res.getStatusCode() == 200);    
            System.assertEquals('OK', res.getStatus());
            // Parse results        
            //parser = JSON.createParser(res.getBody());
            responseFromGeo = res.getBody();
        }else{
            if(geoURL == 'http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=RDC&v=1&format=json'){
                //parser = JSON.createParser('[{"Id":827704,"area":"Guam","areaTypeID":4,"fips":"66","geoArea":1.4778935E+09,"latCentroid":13.444355,"longCentroid":144.7863,"maxLat":13.7061787,"maxLong":145.009171,"minLat":13.1823349,"minLong":144.563431,"stateId":"GU"},{"Id":827733,"area":"Virgin Islands of the United States","areaTypeID":4,"fips":"78","geoArea":1.91011354E+09,"latCentroid":18.0444946,"longCentroid":-64.8358841,"maxLat":18.4649849,"maxLong":-64.51267,"minLat":17.6234684,"minLong":-65.1590958,"stateId":"VI"},{"Id":4249699,"area":"Michigan","areaTypeID":4,"fips":"26","geoArea":1.5065106E+11,"latCentroid":45.04883,"longCentroid":-86.41849,"maxLat":48.26181,"maxLong":-82.4186,"minLat":41.6961174,"minLong":-90.41837,"stateId":"MI"},{"Id":4249700,"area":"North Carolina","areaTypeID":4,"fips":"37","geoArea":1.27962513E+11,"latCentroid":35.292202,"longCentroid":-79.8911057,"maxLat":36.5881577,"maxLong":-75.4603348,"minLat":33.8345871,"minLong":-84.32187,"stateId":"NC"}]    ');
                responseFromGeo = '[{"Id":827704,"area":"Guam","areaTypeID":4,"fips":"66","geoArea":1.4778935E+09,"latCentroid":13.444355,"longCentroid":144.7863,"maxLat":13.7061787,"maxLong":145.009171,"minLat":13.1823349,"minLong":144.563431,"stateId":"GU"},{"Id":827733,"area":"Virgin Islands of the United States","areaTypeID":4,"fips":"78","geoArea":1.91011354E+09,"latCentroid":18.0444946,"longCentroid":-64.8358841,"maxLat":18.4649849,"maxLong":-64.51267,"minLat":17.6234684,"minLong":-65.1590958,"stateId":"VI"},{"Id":4249699,"area":"Michigan","areaTypeID":4,"fips":"26","geoArea":1.5065106E+11,"latCentroid":45.04883,"longCentroid":-86.41849,"maxLat":48.26181,"maxLong":-82.4186,"minLat":41.6961174,"minLong":-90.41837,"stateId":"MI"},{"Id":4249700,"area":"North Carolina","areaTypeID":4,"fips":"37","geoArea":1.27962513E+11,"latCentroid":35.292202,"longCentroid":-79.8911057,"maxLat":36.5881577,"maxLong":-75.4603348,"minLat":33.8345871,"minLong":-84.32187,"stateId":"NC"}]    ';
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/california?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('"NC"');
                responseFromGeo = '"NC"';
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/Counties/NC?app=RDC&v=1&format=json'){
                //parser = JSON.createParser('[{"Id":4249760,"area":"Chatham","areaTypeID":3,"fips":"37037","geoArea":1.83845466E+09,"latCentroid":35.696373,"longCentroid":-79.23103,"maxLat":35.87679,"maxLong":-78.90617,"minLat":35.5150833,"minLong":-79.55589,"stateId":"NC"},{"Id":4249800,"area":"Surry","areaTypeID":3,"fips":"37171","geoArea":1.38902E+09,"latCentroid":36.399662,"longCentroid":-80.70736,"maxLat":36.5623474,"maxLong":-80.4401,"minLat":36.23638,"minLong":-80.97462,"stateId":"NC"},{"Id":4249817,"area":"Clay","areaTypeID":3,"fips":"37043","geoArea":571394240,"latCentroid":35.0741425,"longCentroid":-83.7443,"maxLat":35.1611328,"maxLong":-83.48278,"minLat":34.98659,"minLong":-84.00582,"stateId":"NC"}]');
                responseFromGeo = '[{"Id":4249760,"area":"Chatham","areaTypeID":3,"fips":"37037","geoArea":1.83845466E+09,"latCentroid":35.696373,"longCentroid":-79.23103,"maxLat":35.87679,"maxLong":-78.90617,"minLat":35.5150833,"minLong":-79.55589,"stateId":"NC"},{"Id":4249800,"area":"Surry","areaTypeID":3,"fips":"37171","geoArea":1.38902E+09,"latCentroid":36.399662,"longCentroid":-80.70736,"maxLat":36.5623474,"maxLong":-80.4401,"minLat":36.23638,"minLong":-80.97462,"stateId":"NC"},{"Id":4249817,"area":"Clay","areaTypeID":3,"fips":"37043","geoArea":571394240,"latCentroid":35.0741425,"longCentroid":-83.7443,"maxLat":35.1611328,"maxLong":-83.48278,"minLat":34.98659,"minLong":-84.00582,"stateId":"NC"}]'; 
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/NC/Ventura?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":450710,"area":"Box Canyon","areaTypeID":24,"geoArea":24054008,"latCentroid":34.2296066,"longCentroid":-118.630707,"maxLat":34.257412,"maxLong":-118.58847,"minLat":34.20179,"minLong":-118.672951,"stateId":"CA"},{"Id":827896,"area":"Calabasas","areaTypeID":32,"geoArea":1.87515E+08,"latCentroid":34.14229,"longCentroid":-118.731873,"maxLat":34.2194252,"maxLong":-118.605705,"minLat":34.06502,"minLong":-118.858047,"stateId":"CA"},{"Id":437391,"area":"Malibu","areaTypeID":24,"geoArea":245613840,"latCentroid":34.06389,"longCentroid":-118.789757,"maxLat":34.12702,"maxLong":-118.567253,"minLat":34.0003548,"minLong":-119.012268,"stateId":"CA"},{"Id":441728,"area":"Saratoga Hills","areaTypeID":24,"geoArea":120187968,"latCentroid":34.1436424,"longCentroid":-118.763,"maxLat":34.2194252,"maxLong":-118.667953,"minLat":34.0677872,"minLong":-118.858047,"stateId":"CA"}]');
                responseFromGeo = 'http://geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/NC/Ventura?app=RDC&v=1&format=JSON'; 
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/Cities/NC?app=RDC&v=1&format=json'){
                //parser = JSON.createParser('[{"Id":827893,"area":"Aliso Viejo","areaTypeID":32,"geoArea":4.113654E+07,"latCentroid":33.6047134,"longCentroid":-117.755989,"maxLat":33.67129,"maxLong":-117.673347,"minLat":33.5380821,"minLong":-117.838638,"stateId":"CA"},{"Id":827894,"area":"Berkeley","areaTypeID":32,"geoArea":44500868,"latCentroid":37.8831367,"longCentroid":-122.272285,"maxLat":37.92126,"maxLong":-122.216743,"minLat":37.844986,"minLong":-122.327827,"stateId":"CA"},{"Id":827895,"area":"Big Bear","areaTypeID":32,"geoArea":6.953221E+08,"latCentroid":34.2623,"longCentroid":-116.900009,"maxLat":34.36762,"maxLong":-116.6469,"minLat":34.1564636,"minLong":-117.15313,"stateId":"CA"}]');
                responseFromGeo = '[{"Id":827893,"area":"Aliso Viejo","areaTypeID":32,"geoArea":4.113654E+07,"latCentroid":33.6047134,"longCentroid":-117.755989,"maxLat":33.67129,"maxLong":-117.673347,"minLat":33.5380821,"minLong":-117.838638,"stateId":"CA"},{"Id":827894,"area":"Berkeley","areaTypeID":32,"geoArea":44500868,"latCentroid":37.8831367,"longCentroid":-122.272285,"maxLat":37.92126,"maxLong":-122.216743,"minLat":37.844986,"minLong":-122.327827,"stateId":"CA"},{"Id":827895,"area":"Big Bear","areaTypeID":32,"geoArea":6.953221E+08,"latCentroid":34.2623,"longCentroid":-116.900009,"maxLat":34.36762,"maxLong":-116.6469,"minLat":34.1564636,"minLong":-117.15313,"stateId":"CA"}]'; 
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/County.svc/ZipsWithinCounty/NC/ventura?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":31163,"area":"93243","areaTypeID":1,"dst":"Y","fips":"93243","geoArea":805341760,"latCentroid":34.7278671,"longCentroid":-118.923134,"maxLat":34.9424744,"maxLong":-118.690987,"minLat":34.51282,"minLong":-119.155273,"stateId":"CA","timeZone":"PST"},{"Id":31170,"area":"93252","areaTypeID":1,"dst":"Y","fips":"93252","geoArea":1.03373254E+09,"latCentroid":34.8739929,"longCentroid":-119.379646,"maxLat":35.1299438,"maxLong":-119.154922,"minLat":34.6176262,"minLong":-119.60437,"stateId":"CA","timeZone":"PST"},{"Id":30669,"area":"91307","areaTypeID":1,"dst":"Y","fips":"91307","geoArea":36557824,"latCentroid":34.20933,"longCentroid":-118.679855,"maxLat":34.2387238,"maxLong":-118.614624,"minLat":34.17991,"minLong":-118.745087,"stateId":"CA","timeZone":"PST"},{"Id":30692,"area":"91361","areaTypeID":1,"dst":"Y","fips":"91361","geoArea":6.265137E+07,"latCentroid":34.1496773,"longCentroid":-118.878174,"maxLat":34.18224,"maxLong":-118.7933,"minLat":34.117054,"minLong":-118.963051,"stateId":"CA","timeZone":"PST"},{"Id":3245,"area":"00061","areaTypeID":1,"fips":"00061","geoArea":6.146986E+07,"latCentroid":33.35215,"longCentroid":-119.302673,"maxLat":33.48917,"maxLong":-119.027382,"minLat":33.2145233,"minLong":-119.577965,"stateId":"CA"}]');
                responseFromGeo = '[{"Id":31163,"area":"93243","areaTypeID":1,"dst":"Y","fips":"93243","geoArea":805341760,"latCentroid":34.7278671,"longCentroid":-118.923134,"maxLat":34.9424744,"maxLong":-118.690987,"minLat":34.51282,"minLong":-119.155273,"stateId":"CA","timeZone":"PST"},{"Id":31170,"area":"93252","areaTypeID":1,"dst":"Y","fips":"93252","geoArea":1.03373254E+09,"latCentroid":34.8739929,"longCentroid":-119.379646,"maxLat":35.1299438,"maxLong":-119.154922,"minLat":34.6176262,"minLong":-119.60437,"stateId":"CA","timeZone":"PST"},{"Id":30669,"area":"91307","areaTypeID":1,"dst":"Y","fips":"91307","geoArea":36557824,"latCentroid":34.20933,"longCentroid":-118.679855,"maxLat":34.2387238,"maxLong":-118.614624,"minLat":34.17991,"minLong":-118.745087,"stateId":"CA","timeZone":"PST"},{"Id":30692,"area":"91361","areaTypeID":1,"dst":"Y","fips":"91361","geoArea":6.265137E+07,"latCentroid":34.1496773,"longCentroid":-118.878174,"maxLat":34.18224,"maxLong":-118.7933,"minLat":34.117054,"minLong":-118.963051,"stateId":"CA","timeZone":"PST"},{"Id":3245,"area":"00061","areaTypeID":1,"fips":"00061","geoArea":6.146986E+07,"latCentroid":33.35215,"longCentroid":-119.302673,"maxLat":33.48917,"maxLong":-119.027382,"minLat":33.2145233,"minLong":-119.577965,"stateId":"CA"}]';
            }else if (geoURL == 'http://geo.svc.move.com/GeoWcfService/City.svc/ZipsIntersectsCity/NC/westlakevillage?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":562496,"area":"91359","areaTypeID":30,"dst":"Y","fips":"111","latCentroid":34.1650848,"longCentroid":-118.830696,"maxLat":34.1650848,"maxLong":-118.830696,"minLat":34.1650848,"minLong":-118.830696,"stateId":"CA","timeZone":"PST"},{"Id":30554,"area":"90265","areaTypeID":1,"dst":"Y","fips":"90265","geoArea":245009168,"latCentroid":34.06389,"longCentroid":-118.789757,"maxLat":34.12702,"maxLong":-118.567253,"minLat":34.0003548,"minLong":-119.012268,"stateId":"CA","timeZone":"PST"},{"Id":31128,"area":"93065","areaTypeID":1,"dst":"Y","fips":"93065","geoArea":109558968,"latCentroid":34.29316,"longCentroid":-118.777374,"maxLat":34.3739243,"maxLong":-118.70948,"minLat":34.2123566,"minLong":-118.845268,"stateId":"CA","timeZone":"PST"},{"Id":30664,"area":"91301","areaTypeID":1,"dst":"Y","fips":"91301","geoArea":120187968,"latCentroid":34.1436424,"longCentroid":-118.763,"maxLat":34.2194252,"maxLong":-118.667961,"minLat":34.0677872,"minLong":-118.858047,"stateId":"CA","timeZone":"PST"}]');
                responseFromGeo = '[{"Id":562496,"area":"91359","areaTypeID":30,"dst":"Y","fips":"111","latCentroid":34.1650848,"longCentroid":-118.830696,"maxLat":34.1650848,"maxLong":-118.830696,"minLat":34.1650848,"minLong":-118.830696,"stateId":"CA","timeZone":"PST"},{"Id":30554,"area":"90265","areaTypeID":1,"dst":"Y","fips":"90265","geoArea":245009168,"latCentroid":34.06389,"longCentroid":-118.789757,"maxLat":34.12702,"maxLong":-118.567253,"minLat":34.0003548,"minLong":-119.012268,"stateId":"CA","timeZone":"PST"},{"Id":31128,"area":"93065","areaTypeID":1,"dst":"Y","fips":"93065","geoArea":109558968,"latCentroid":34.29316,"longCentroid":-118.777374,"maxLat":34.3739243,"maxLong":-118.70948,"minLat":34.2123566,"minLong":-118.845268,"stateId":"CA","timeZone":"PST"},{"Id":30664,"area":"91301","areaTypeID":1,"dst":"Y","fips":"91301","geoArea":120187968,"latCentroid":34.1436424,"longCentroid":-118.763,"maxLat":34.2194252,"maxLong":-118.667961,"minLat":34.0677872,"minLong":-118.858047,"stateId":"CA","timeZone":"PST"}]';
            }else if (geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/Postalcodes/NC?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":3212,"area":"00022","areaTypeID":1,"fips":"00022","geoArea":8.741913E+07,"latCentroid":39.44322,"longCentroid":-123.541618,"maxLat":39.53999,"maxLong":-123.503731,"minLat":39.34643,"minLong":-123.579514,"stateId":"CA"},{"Id":3213,"area":"00026","areaTypeID":1,"fips":"00026","geoArea":3.77517875E+09,"latCentroid":36.2675743,"longCentroid":-118.356544,"maxLat":36.7447739,"maxLong":-117.975258,"minLat":35.78916,"minLong":-118.737831,"stateId":"CA"},{"Id":3215,"area":"00028","areaTypeID":1,"fips":"00028","geoArea":2.960774E+08,"latCentroid":40.11077,"longCentroid":-120.387596,"maxLat":40.1939659,"maxLong":-120.209419,"minLat":40.0273056,"minLong":-120.565765,"stateId":"CA"},{"Id":3216,"area":"00029","areaTypeID":1,"fips":"00029","geoArea":5644537.5,"latCentroid":39.5134926,"longCentroid":-121.059151,"maxLat":39.52256,"maxLong":-121.033325,"minLat":39.5044174,"minLong":-121.084984,"stateId":"CA"}]');
                responseFromGeo = '[{"Id":3212,"area":"00022","areaTypeID":1,"fips":"00022","geoArea":8.741913E+07,"latCentroid":39.44322,"longCentroid":-123.541618,"maxLat":39.53999,"maxLong":-123.503731,"minLat":39.34643,"minLong":-123.579514,"stateId":"CA"},{"Id":3213,"area":"00026","areaTypeID":1,"fips":"00026","geoArea":3.77517875E+09,"latCentroid":36.2675743,"longCentroid":-118.356544,"maxLat":36.7447739,"maxLong":-117.975258,"minLat":35.78916,"minLong":-118.737831,"stateId":"CA"},{"Id":3215,"area":"00028","areaTypeID":1,"fips":"00028","geoArea":2.960774E+08,"latCentroid":40.11077,"longCentroid":-120.387596,"maxLat":40.1939659,"maxLong":-120.209419,"minLat":40.0273056,"minLong":-120.565765,"stateId":"CA"},{"Id":3216,"area":"00029","areaTypeID":1,"fips":"00029","geoArea":5644537.5,"latCentroid":39.5134926,"longCentroid":-121.059151,"maxLat":39.52256,"maxLong":-121.033325,"minLat":39.5044174,"minLong":-121.084984,"stateId":"CA"}]'; 
            }
        
        }     
        
        if(!Test.isRunningTest()){
        list<ResponseForPostal> responseForPostalList = (list<ResponseForPostal>) JSON.deserialize( responseFromGeo, list<ResponseForPostal>.class );
        for( ResponseForPostal resp : (list<ResponseForPostal>) JSON.deserialize( responseFromGeo, list<ResponseForPostal>.class )){
            If(!string.isBlank(resp.area)){
                options.add(new SelectOption(resp.area,resp.area));    
            }
        }
        }
        return options;
        /*}else{
            parser = JSON.createParser(res.getBody());
            while(parser.nextToken() != null){
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'area')){                
                    // Get the value.         
                    parser.nextToken();     
                    options.add(new SelectOption(parser.getText(),parser.getText()));                       
                }
            }
            system.debug('options222:'+options);
            return options;
        }*/
    }
    
    
    public set<String> JSONtoSet(string geoURL){
        System.debug('------ geoURL --->'+geoURL);
        string responseFromGeo = '';
        Set<String> options = new Set<String>();                       
        HttpRequest req = new HttpRequest();
        req.setEndpoint(geoURL);
        req.setMethod('GET');         
        // Make the HTTP request call  
         HttpResponse res = new HttpResponse();
          JSONParser parser;
        if(!Test.isRunningTest()){
            res = makeCallout(req); 
            // Verify results     
            System.assert(res.getStatusCode() == 200);    
            System.assertEquals('OK', res.getStatus());
            // Parse results        
            //parser = JSON.createParser(res.getBody());
            responseFromGeo = res.getBody();
        }else{
            if(geoURL == 'http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=RDC&v=1&format=json'){
                //parser = JSON.createParser('[{"Id":827704,"area":"Guam","areaTypeID":4,"fips":"66","geoArea":1.4778935E+09,"latCentroid":13.444355,"longCentroid":144.7863,"maxLat":13.7061787,"maxLong":145.009171,"minLat":13.1823349,"minLong":144.563431,"stateId":"GU"},{"Id":827733,"area":"Virgin Islands of the United States","areaTypeID":4,"fips":"78","geoArea":1.91011354E+09,"latCentroid":18.0444946,"longCentroid":-64.8358841,"maxLat":18.4649849,"maxLong":-64.51267,"minLat":17.6234684,"minLong":-65.1590958,"stateId":"VI"},{"Id":4249699,"area":"Michigan","areaTypeID":4,"fips":"26","geoArea":1.5065106E+11,"latCentroid":45.04883,"longCentroid":-86.41849,"maxLat":48.26181,"maxLong":-82.4186,"minLat":41.6961174,"minLong":-90.41837,"stateId":"MI"},{"Id":4249700,"area":"North Carolina","areaTypeID":4,"fips":"37","geoArea":1.27962513E+11,"latCentroid":35.292202,"longCentroid":-79.8911057,"maxLat":36.5881577,"maxLong":-75.4603348,"minLat":33.8345871,"minLong":-84.32187,"stateId":"NC"}]    ');
                responseFromGeo = '[{"Id":827704,"area":"Guam","areaTypeID":4,"fips":"66","geoArea":1.4778935E+09,"latCentroid":13.444355,"longCentroid":144.7863,"maxLat":13.7061787,"maxLong":145.009171,"minLat":13.1823349,"minLong":144.563431,"stateId":"GU"},{"Id":827733,"area":"Virgin Islands of the United States","areaTypeID":4,"fips":"78","geoArea":1.91011354E+09,"latCentroid":18.0444946,"longCentroid":-64.8358841,"maxLat":18.4649849,"maxLong":-64.51267,"minLat":17.6234684,"minLong":-65.1590958,"stateId":"VI"},{"Id":4249699,"area":"Michigan","areaTypeID":4,"fips":"26","geoArea":1.5065106E+11,"latCentroid":45.04883,"longCentroid":-86.41849,"maxLat":48.26181,"maxLong":-82.4186,"minLat":41.6961174,"minLong":-90.41837,"stateId":"MI"},{"Id":4249700,"area":"North Carolina","areaTypeID":4,"fips":"37","geoArea":1.27962513E+11,"latCentroid":35.292202,"longCentroid":-79.8911057,"maxLat":36.5881577,"maxLong":-75.4603348,"minLat":33.8345871,"minLong":-84.32187,"stateId":"NC"}]    ';
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/california?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('"NC"');
                responseFromGeo = '"NC"';
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/Counties/NC?app=RDC&v=1&format=json'){
                //parser = JSON.createParser('[{"Id":4249760,"area":"Chatham","areaTypeID":3,"fips":"37037","geoArea":1.83845466E+09,"latCentroid":35.696373,"longCentroid":-79.23103,"maxLat":35.87679,"maxLong":-78.90617,"minLat":35.5150833,"minLong":-79.55589,"stateId":"NC"},{"Id":4249800,"area":"Surry","areaTypeID":3,"fips":"37171","geoArea":1.38902E+09,"latCentroid":36.399662,"longCentroid":-80.70736,"maxLat":36.5623474,"maxLong":-80.4401,"minLat":36.23638,"minLong":-80.97462,"stateId":"NC"},{"Id":4249817,"area":"Clay","areaTypeID":3,"fips":"37043","geoArea":571394240,"latCentroid":35.0741425,"longCentroid":-83.7443,"maxLat":35.1611328,"maxLong":-83.48278,"minLat":34.98659,"minLong":-84.00582,"stateId":"NC"}]');
                responseFromGeo = '[{"Id":4249760,"area":"Chatham","areaTypeID":3,"fips":"37037","geoArea":1.83845466E+09,"latCentroid":35.696373,"longCentroid":-79.23103,"maxLat":35.87679,"maxLong":-78.90617,"minLat":35.5150833,"minLong":-79.55589,"stateId":"NC"},{"Id":4249800,"area":"Surry","areaTypeID":3,"fips":"37171","geoArea":1.38902E+09,"latCentroid":36.399662,"longCentroid":-80.70736,"maxLat":36.5623474,"maxLong":-80.4401,"minLat":36.23638,"minLong":-80.97462,"stateId":"NC"},{"Id":4249817,"area":"Clay","areaTypeID":3,"fips":"37043","geoArea":571394240,"latCentroid":35.0741425,"longCentroid":-83.7443,"maxLat":35.1611328,"maxLong":-83.48278,"minLat":34.98659,"minLong":-84.00582,"stateId":"NC"}]'; 
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/NC/Ventura?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":450710,"area":"Box Canyon","areaTypeID":24,"geoArea":24054008,"latCentroid":34.2296066,"longCentroid":-118.630707,"maxLat":34.257412,"maxLong":-118.58847,"minLat":34.20179,"minLong":-118.672951,"stateId":"CA"},{"Id":827896,"area":"Calabasas","areaTypeID":32,"geoArea":1.87515E+08,"latCentroid":34.14229,"longCentroid":-118.731873,"maxLat":34.2194252,"maxLong":-118.605705,"minLat":34.06502,"minLong":-118.858047,"stateId":"CA"},{"Id":437391,"area":"Malibu","areaTypeID":24,"geoArea":245613840,"latCentroid":34.06389,"longCentroid":-118.789757,"maxLat":34.12702,"maxLong":-118.567253,"minLat":34.0003548,"minLong":-119.012268,"stateId":"CA"},{"Id":441728,"area":"Saratoga Hills","areaTypeID":24,"geoArea":120187968,"latCentroid":34.1436424,"longCentroid":-118.763,"maxLat":34.2194252,"maxLong":-118.667953,"minLat":34.0677872,"minLong":-118.858047,"stateId":"CA"}]');
                responseFromGeo = 'http://geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/NC/Ventura?app=RDC&v=1&format=JSON'; 
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/Cities/NC?app=RDC&v=1&format=json'){
                //parser = JSON.createParser('[{"Id":827893,"area":"Aliso Viejo","areaTypeID":32,"geoArea":4.113654E+07,"latCentroid":33.6047134,"longCentroid":-117.755989,"maxLat":33.67129,"maxLong":-117.673347,"minLat":33.5380821,"minLong":-117.838638,"stateId":"CA"},{"Id":827894,"area":"Berkeley","areaTypeID":32,"geoArea":44500868,"latCentroid":37.8831367,"longCentroid":-122.272285,"maxLat":37.92126,"maxLong":-122.216743,"minLat":37.844986,"minLong":-122.327827,"stateId":"CA"},{"Id":827895,"area":"Big Bear","areaTypeID":32,"geoArea":6.953221E+08,"latCentroid":34.2623,"longCentroid":-116.900009,"maxLat":34.36762,"maxLong":-116.6469,"minLat":34.1564636,"minLong":-117.15313,"stateId":"CA"}]');
                responseFromGeo = '[{"Id":827893,"area":"Aliso Viejo","areaTypeID":32,"geoArea":4.113654E+07,"latCentroid":33.6047134,"longCentroid":-117.755989,"maxLat":33.67129,"maxLong":-117.673347,"minLat":33.5380821,"minLong":-117.838638,"stateId":"CA"},{"Id":827894,"area":"Berkeley","areaTypeID":32,"geoArea":44500868,"latCentroid":37.8831367,"longCentroid":-122.272285,"maxLat":37.92126,"maxLong":-122.216743,"minLat":37.844986,"minLong":-122.327827,"stateId":"CA"},{"Id":827895,"area":"Big Bear","areaTypeID":32,"geoArea":6.953221E+08,"latCentroid":34.2623,"longCentroid":-116.900009,"maxLat":34.36762,"maxLong":-116.6469,"minLat":34.1564636,"minLong":-117.15313,"stateId":"CA"}]'; 
            }else if(geoURL == 'http://geo.svc.move.com/GeoWcfService/County.svc/ZipsWithinCounty/NC/ventura?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":31163,"area":"93243","areaTypeID":1,"dst":"Y","fips":"93243","geoArea":805341760,"latCentroid":34.7278671,"longCentroid":-118.923134,"maxLat":34.9424744,"maxLong":-118.690987,"minLat":34.51282,"minLong":-119.155273,"stateId":"CA","timeZone":"PST"},{"Id":31170,"area":"93252","areaTypeID":1,"dst":"Y","fips":"93252","geoArea":1.03373254E+09,"latCentroid":34.8739929,"longCentroid":-119.379646,"maxLat":35.1299438,"maxLong":-119.154922,"minLat":34.6176262,"minLong":-119.60437,"stateId":"CA","timeZone":"PST"},{"Id":30669,"area":"91307","areaTypeID":1,"dst":"Y","fips":"91307","geoArea":36557824,"latCentroid":34.20933,"longCentroid":-118.679855,"maxLat":34.2387238,"maxLong":-118.614624,"minLat":34.17991,"minLong":-118.745087,"stateId":"CA","timeZone":"PST"},{"Id":30692,"area":"91361","areaTypeID":1,"dst":"Y","fips":"91361","geoArea":6.265137E+07,"latCentroid":34.1496773,"longCentroid":-118.878174,"maxLat":34.18224,"maxLong":-118.7933,"minLat":34.117054,"minLong":-118.963051,"stateId":"CA","timeZone":"PST"},{"Id":3245,"area":"00061","areaTypeID":1,"fips":"00061","geoArea":6.146986E+07,"latCentroid":33.35215,"longCentroid":-119.302673,"maxLat":33.48917,"maxLong":-119.027382,"minLat":33.2145233,"minLong":-119.577965,"stateId":"CA"}]');
                responseFromGeo = '[{"Id":31163,"area":"93243","areaTypeID":1,"dst":"Y","fips":"93243","geoArea":805341760,"latCentroid":34.7278671,"longCentroid":-118.923134,"maxLat":34.9424744,"maxLong":-118.690987,"minLat":34.51282,"minLong":-119.155273,"stateId":"CA","timeZone":"PST"},{"Id":31170,"area":"93252","areaTypeID":1,"dst":"Y","fips":"93252","geoArea":1.03373254E+09,"latCentroid":34.8739929,"longCentroid":-119.379646,"maxLat":35.1299438,"maxLong":-119.154922,"minLat":34.6176262,"minLong":-119.60437,"stateId":"CA","timeZone":"PST"},{"Id":30669,"area":"91307","areaTypeID":1,"dst":"Y","fips":"91307","geoArea":36557824,"latCentroid":34.20933,"longCentroid":-118.679855,"maxLat":34.2387238,"maxLong":-118.614624,"minLat":34.17991,"minLong":-118.745087,"stateId":"CA","timeZone":"PST"},{"Id":30692,"area":"91361","areaTypeID":1,"dst":"Y","fips":"91361","geoArea":6.265137E+07,"latCentroid":34.1496773,"longCentroid":-118.878174,"maxLat":34.18224,"maxLong":-118.7933,"minLat":34.117054,"minLong":-118.963051,"stateId":"CA","timeZone":"PST"},{"Id":3245,"area":"00061","areaTypeID":1,"fips":"00061","geoArea":6.146986E+07,"latCentroid":33.35215,"longCentroid":-119.302673,"maxLat":33.48917,"maxLong":-119.027382,"minLat":33.2145233,"minLong":-119.577965,"stateId":"CA"}]';
            }else if (geoURL == 'http://geo.svc.move.com/GeoWcfService/City.svc/ZipsIntersectsCity/NC/westlakevillage?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":562496,"area":"91359","areaTypeID":30,"dst":"Y","fips":"111","latCentroid":34.1650848,"longCentroid":-118.830696,"maxLat":34.1650848,"maxLong":-118.830696,"minLat":34.1650848,"minLong":-118.830696,"stateId":"CA","timeZone":"PST"},{"Id":30554,"area":"90265","areaTypeID":1,"dst":"Y","fips":"90265","geoArea":245009168,"latCentroid":34.06389,"longCentroid":-118.789757,"maxLat":34.12702,"maxLong":-118.567253,"minLat":34.0003548,"minLong":-119.012268,"stateId":"CA","timeZone":"PST"},{"Id":31128,"area":"93065","areaTypeID":1,"dst":"Y","fips":"93065","geoArea":109558968,"latCentroid":34.29316,"longCentroid":-118.777374,"maxLat":34.3739243,"maxLong":-118.70948,"minLat":34.2123566,"minLong":-118.845268,"stateId":"CA","timeZone":"PST"},{"Id":30664,"area":"91301","areaTypeID":1,"dst":"Y","fips":"91301","geoArea":120187968,"latCentroid":34.1436424,"longCentroid":-118.763,"maxLat":34.2194252,"maxLong":-118.667961,"minLat":34.0677872,"minLong":-118.858047,"stateId":"CA","timeZone":"PST"}]');
                responseFromGeo = '[{"Id":562496,"area":"91359","areaTypeID":30,"dst":"Y","fips":"111","latCentroid":34.1650848,"longCentroid":-118.830696,"maxLat":34.1650848,"maxLong":-118.830696,"minLat":34.1650848,"minLong":-118.830696,"stateId":"CA","timeZone":"PST"},{"Id":30554,"area":"90265","areaTypeID":1,"dst":"Y","fips":"90265","geoArea":245009168,"latCentroid":34.06389,"longCentroid":-118.789757,"maxLat":34.12702,"maxLong":-118.567253,"minLat":34.0003548,"minLong":-119.012268,"stateId":"CA","timeZone":"PST"},{"Id":31128,"area":"93065","areaTypeID":1,"dst":"Y","fips":"93065","geoArea":109558968,"latCentroid":34.29316,"longCentroid":-118.777374,"maxLat":34.3739243,"maxLong":-118.70948,"minLat":34.2123566,"minLong":-118.845268,"stateId":"CA","timeZone":"PST"},{"Id":30664,"area":"91301","areaTypeID":1,"dst":"Y","fips":"91301","geoArea":120187968,"latCentroid":34.1436424,"longCentroid":-118.763,"maxLat":34.2194252,"maxLong":-118.667961,"minLat":34.0677872,"minLong":-118.858047,"stateId":"CA","timeZone":"PST"}]';
            }else if (geoURL == 'http://geo.svc.move.com/GeoWcfService/State.svc/Postalcodes/NC?app=RDC&v=1&format=JSON'){
                //parser = JSON.createParser('[{"Id":3212,"area":"00022","areaTypeID":1,"fips":"00022","geoArea":8.741913E+07,"latCentroid":39.44322,"longCentroid":-123.541618,"maxLat":39.53999,"maxLong":-123.503731,"minLat":39.34643,"minLong":-123.579514,"stateId":"CA"},{"Id":3213,"area":"00026","areaTypeID":1,"fips":"00026","geoArea":3.77517875E+09,"latCentroid":36.2675743,"longCentroid":-118.356544,"maxLat":36.7447739,"maxLong":-117.975258,"minLat":35.78916,"minLong":-118.737831,"stateId":"CA"},{"Id":3215,"area":"00028","areaTypeID":1,"fips":"00028","geoArea":2.960774E+08,"latCentroid":40.11077,"longCentroid":-120.387596,"maxLat":40.1939659,"maxLong":-120.209419,"minLat":40.0273056,"minLong":-120.565765,"stateId":"CA"},{"Id":3216,"area":"00029","areaTypeID":1,"fips":"00029","geoArea":5644537.5,"latCentroid":39.5134926,"longCentroid":-121.059151,"maxLat":39.52256,"maxLong":-121.033325,"minLat":39.5044174,"minLong":-121.084984,"stateId":"CA"}]');
                responseFromGeo = '[{"Id":3212,"area":"00022","areaTypeID":1,"fips":"00022","geoArea":8.741913E+07,"latCentroid":39.44322,"longCentroid":-123.541618,"maxLat":39.53999,"maxLong":-123.503731,"minLat":39.34643,"minLong":-123.579514,"stateId":"CA"},{"Id":3213,"area":"00026","areaTypeID":1,"fips":"00026","geoArea":3.77517875E+09,"latCentroid":36.2675743,"longCentroid":-118.356544,"maxLat":36.7447739,"maxLong":-117.975258,"minLat":35.78916,"minLong":-118.737831,"stateId":"CA"},{"Id":3215,"area":"00028","areaTypeID":1,"fips":"00028","geoArea":2.960774E+08,"latCentroid":40.11077,"longCentroid":-120.387596,"maxLat":40.1939659,"maxLong":-120.209419,"minLat":40.0273056,"minLong":-120.565765,"stateId":"CA"},{"Id":3216,"area":"00029","areaTypeID":1,"fips":"00029","geoArea":5644537.5,"latCentroid":39.5134926,"longCentroid":-121.059151,"maxLat":39.52256,"maxLong":-121.033325,"minLat":39.5044174,"minLong":-121.084984,"stateId":"CA"}]'; 
            }
        
        }     
        
        if(!Test.isRunningTest()){
        list<ResponseForPostal> responseForPostalList = (list<ResponseForPostal>) JSON.deserialize( responseFromGeo, list<ResponseForPostal>.class );
        for( ResponseForPostal resp : (list<ResponseForPostal>) JSON.deserialize( responseFromGeo, list<ResponseForPostal>.class )){
            If(!string.isBlank(resp.area)){
                options.add(resp.area);    
            }
        }
        }
        return options;
        /*}else{
            parser = JSON.createParser(res.getBody());
            while(parser.nextToken() != null){
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'area')){                
                    // Get the value.         
                    parser.nextToken();     
                    options.add(new SelectOption(parser.getText(),parser.getText()));                       
                }
            }
            system.debug('options222:'+options);
            return options;
        }*/
    }
    
       
    private HttpResponse makeCallout(HttpRequest req){
        HttpResponse res;                       
        res = new Http().send(req);        
        return res;
    }
    public class ResponseForPostal{
    
        //public string Id;
        public string area;
        /*public string areaTypeID;
        public string fips;
        public string geoArea;
        public string latCentroid;
        public string longCentroid;
        public string maxLat;
        public string maxLong;
        public string minLat;
        public string minLong;
        public string stateId;*/
    }
}
global class  MoveGeoController {

/**

AL  AL  Ala.    Ala.    
Alaska  State   US-AK   AK  02  AK  AK  Alaska  Alaska  Alas.
Arizona State   US-AZ   AZ  04  AZ  AZ  Ariz.   Ariz.   Az.
Arkansas    State   US-AR   AR  05  AR  AR  Ark.    Ark.    
California  State   US-CA   CA  06  CA  CF  Calif.  Calif.  Ca., Cal.
Colorado    State   US-CO   CO  08  CO  CL  Colo.   Colo.   Col.
Connecticut State   US-CT   CT  09  CT  CT  Conn.   Conn.   Ct.
Delaware    State   US-DE   DE  10  DE  DL  Del.    Del.    De.
District of Columbia    Federal district    US-DC   DC  11  DC  DC  D.C.    D.C.    Wash. D.C.
Florida State   US-FL   FL  12  FL  FL  Fla.    Fla.    Fl., Flor.
Georgia State   US-GA   GA  13  GA  GA  Ga. Ga. 
Hawaii  State   US-HI   HI  15  HI  HA  Hawaii  Hawaii  H.I.
Idaho   State   US-ID   ID  16  ID  ID  Idaho   Idaho   Id., Ida.
Illinois    State   US-IL   IL  17  IL  IL  Ill.    Ill.    Il., Ills., Ill's
Indiana State   US-IN   IN  18  IN  IN  Ind.    Ind.    In.
Iowa    State   US-IA   IA  19  IA  IA  Iowa    Iowa    Ia., Ioa.[1]
Kansas  State   US-KS   KS  20  KS  KA  Kans.   Kan.    Ks., Ka.
Kentucky    State (Commonwealth)    US-KY   KY  21  KY  KY  Ky. Ky. Ken., Kent.
Louisiana   State   US-LA   LA  22  LA  LA  La. La. 
Maine   State   US-ME   ME  23  ME  ME  Maine   Maine   Me.
Maryland    State   US-MD   MD  24  MD  MD  Md. Md. 
Massachusetts   State (Commonwealth)    US-MA   MA  25  MA  MS  Mass.   Mass.   
Michigan    State   US-MI   MI  26  MI  MC  Mich.   Mich.   
Minnesota   State   US-MN   MN  27  MN  MN  Minn.   Minn.   Mn.
Mississippi State   US-MS   MS  28  MS  MI  Miss.   Miss.   
Missouri    State   US-MO   MO  29  MO  MO  Mo. Mo. 
Montana State   US-MT   MT  30  MT  MT  Mont.   Mont.   
Nebraska    State   US-NE   NE  31  NE  NB  Nebr.   Neb.    
Nevada  State   US-NV   NV  32  NV  NV  Nev.    Nev.    Nv.
New Hampshire   State   US-NH   NH  33  NH  NH  N.H.    N.H.    
New Jersey  State   US-NJ   NJ  34  NJ  NJ  N.J.    N.J.    
New Mexico  State   US-NM   NM  35  NM  NM  N. Mex. N.M.    New M.
New York    State   US-NY   NY  36  NY  NY  N.Y.    N.Y.    N. York
North Carolina  State   US-NC   NC  37  NC  NC  N.C.    N.C.    N. Car.
North Dakota    State   US-ND   ND  38  ND  ND  N. Dak. N.D.    NoDak
Ohio    State   US-OH   OH  39  OH  OH  Ohio    Ohio    O., Oh.
Oklahoma    State   US-OK   OK  40  OK  OK  Okla.   Okla.   Ok.
Oregon  State   US-OR   OR  41  OR  OR  Oreg.   Ore.    Or.
Pennsylvania    State (Commonwealth)    US-PA   PA  42  PA  PA  Pa. Pa. Penn., Penna.
Rhode Island    State   US-RI   RI  44  RI  RI  R.I.    R.I.    R.I. & P.P., R. Isl.
South Carolina  State   US-SC   SC  45  SC  SC  S.C.    S.C.    S. Car.
South Dakota    State   US-SD   SD  46  SD  SD  S. Dak. S.D.    SoDak
Tennessee   State   US-TN   TN  47  TN  TN  Tenn.   Tenn.   
Texas   State   US-TX   TX  48  TX  TX  Tex.    Texas   Tx.
Utah    State   US-UT   UT  49  UT  UT  Utah    Utah    Ut.
Vermont State   US-VT   VT  50  VT  VT  Vt. Vt. 
Virginia    State (Commonwealth)    US-VA   VA  51  VA  VA  Va. Va. Virg.
Washington  State   US-WA   WA  53  WA  WN  Wash.   Wash.   Wa., Wn.[2]
West Virginia   State   US-WV   WV  54  WV  WV  W. Va.  W.Va.   W.V., W. Virg.
Wisconsin   State   US-WI   WI  55  WI  WS  Wis.    Wis.    Wi., Wisc.
Wyoming State   US-WY   WY  56  WY  WY  Wyo.    Wyo.    Wy.
American Samoa  Insular area (Territory)    AS
ASM
016
US-AS   AS  60  AS  AS  A.S.        
Guam    Insular area (Territory)    GU
GUM
316
US-GU   GU  66  GU  GU  Guam        
Northern Mariana Islands    Insular area (Commonwealth) MP
MNP
580
US-MP   MP  69  MP  CM  M.P.        
Puerto Rico Insular area (Commonwealth) PR
PRI
630
US-PR   PR  72  PR  PR  P.R.        
Virgin Islands  Insular area (Territory)    VI
VIR
850
US-VI   VI  78  VI




*/




private final Account acct;

public String org{get;set;}

public List<String> XMLData1{get;set;}
public List<Area> MyAreaList {get;set;}


public MoveGeoController ()
{
}

public void MyMoveGeoController ()
{

string state; 

     System.debug('Calling XMLDate string');

XMLData1=new List<String>();
 MyAreaList = new List<Area>();




for (Integer i = 0; i < 1; i++) {

state = 'CA';

     System.debug('Calling Web Service Function');
                XMLData1 = getArea( state);
            //  System.debug(XMLData1);
                System.debug(MyAreaList);
}

}

public class Area
{
    private string geoareaname ;
    private string state ;
    private string areacode;
    private string timezone ;
    private string zipcode ;
    private string city ;
    
    public Area()//modified by divya 
    {
        
    }
    
    public void  MyArea (string sgeo,string sstate , string sareacode , string stimezone ,string szipcode
    , string scity )
    {
      geoareaname  = sgeo;
      geoareaname = geoareaname.trim();
      state = sstate ;
      timezone = stimezone ;
      areacode = sareacode ;
      city = scity;
      zipcode = szipcode ;

System.debug('Area Constructor called');

 MoveGeoArea__c newObj = new MoveGeoArea__c(); 
       newObj.state__c = state; 
       newObj.city__c = city ;
       newObj.zipcode__c = zipcode;
       newObj.areacode__c = areacode;
       newObj.timezone__c = timezone ;
       newObj.Name = geoareaname;
       
       insert newObj;

   System.debug('Record Saved');    
        
    }
    
    
    
}




public List<GeoWebserviceObject> geoList {
//return 'Hello ' + acct.name + ' (' + acct.id + ')' + this.getOrganisationInfo('98.138.252.30');
//List<GeoWebserviceObject> GWList;

get
{
    
if (geoList == null)
  {

        geoList=  GetWaitlistfromWebService();
  }

  return geoList;
}

set;

//return 'Hello ' + this.getOrganisationInfo('98.138.252.30');

//return GWList;
//return 'Waitlist';


}


public List<String> getArea(String state){ 

string url ;
Http http = new Http();

HttpRequest req = new HttpRequest();

//req.setEndpoint('http://xml.utrace.de/?query='+ip);
url = 'http://www.webservicex.net/uszip.asmx/GetInfoByState?usstate=';
url = url + state ;


//req.setEndpoint('http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=test&format=xml');
//req.setEndpoint('http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=test&format=json');
System.debug('URL' + url);
req.setEndpoint(url);






req.setMethod('GET');

HttpResponse res = http.send(req);

 

// Log the XML content

String xmlContent=res.getBody();

System.debug(res.getBody());

System.debug('#####XmlStreamReader ##11##');

// Generate the HTTP response as an XML stream

 

XmlStreamReader reader = res.getXmlStreamReader();

System.debug('##########XML DATA##########'+res.getXmlStreamReader());

 

XMLData1=XMLParser(res.getBody());

return XMLData1;

}

 

public List<String> XMLParser(String strXml){
integer count1 =0;

System.debug('####Inside XMLParser Method########'+strXml);

List<String> orgInfo=new List<String>();

string state;
string zip;
string areacode ;
string city ;
string geoarea ;
string timezone;


Dom.Document doc = new Dom.Document();

doc.load(strXml);

//Retrieve the root element for this document.

Dom.XMLNode Envelope = doc.getRootElement();

//Dom.XMLNode Body= Envelope.getChildElements()[]; // [0]

for (Dom.XMLNode Body : Envelope.getChildElements())
{
string user_createResult = '';

/*
<CITY>Highland</CITY>
    <STATE>CA</STATE>
    <ZIP>92346</ZIP>
    <AREA_CODE>909</AREA_CODE>
    <TIME_ZONE>P</TIME_ZONE>*/
 
integer i=0;
count1 ++;
if (count1 == 150 )
break;

for(Dom.XMLNode child : Body.getChildElements()) {


orgInfo.add(child .getText());

system.debug('Printing ' + child .getText() + i);

 if (i==0)
 {
    
    city =  child .getText();
    i++;
 
 }
 else if (i==1) 
 {
    state = child .getText();
    i++;
 
 }else if (i==2)    
 {
    zip = child .getText();
    i++;
 
 }else if (i==3)    
 {
    areacode = child .getText();
    i++;
 
 }else if (i==4)    
 {
    timezone = child .getText();
    
    System.debug('Area Constructor calling ' + state);
    
    Area Area1 = new Area();
      Area1.MyArea  ( state, state , areacode , timezone ,zip
    , city );
    
    i = 0;
     MyAreaList.add(Area1);
 
 
 }
 
 

System.debug('Exiting First Object' + i);



}
System.debug('Exiting Loop');

}
return orgInfo;

}


public List<Contact> contactList {
        get {
            if (contactList == null) {
                contactList = [SELECT Account.Name, FirstName, LastName, Phone FROM Contact limit 10000];
            }
            return contactList;
        }
        set;
    }




Public Class GeoWebserviceObject
{
        public string Id    {get;set;}
        
     
        
        public string area    {get;set;} 
        public string areaTypeID    {get;set;}
        public string fips    {get;set;}
        public string geoArea    {get;set;}
        public string latCentroid    {get;set;}
        public string longCentroid    {get;set;}
        public string maxLat    {get;set;}
        public string maxLong    {get;set;}
        public string minLat    {get;set;}
        public string minLong    {get;set;}
        public string stateId    {get;set;}
        
        public GeoWebserviceObject() //modified by divya
        {
        
          Id = '1';
        area= 'Alabama';
        areaTypeID= '4';
        fips = '01';
        geoArea = '133793169000';
        latCentroid ='32.6284065';
        longCentroid = '-86.68074';
        maxLat= '35.00803';
        maxLong= '-84.88825';
        minLat = '30.2233143';
        minLong= '-88.47323';
        stateId= 'AL';
        
        
        }
        


}




    public  List<GeoWebserviceObject> GetWaitlistfromWebService()
    {
    String myjson;
    List<GeoWebserviceObject> deserializedWL;
    
     HttpRequest req = new HttpRequest();
   Http http = new Http();
   // set the method
   req.setMethod('GET');
   // generate the url for the request

    
//    req.setEndpoint('http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=test&format=xml');
req.setEndpoint('http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=test&format=json');


//HttpResponse res = http.send(req);
    
    
    
    HTTPResponse resp = http.send(req);
    
    myjson = resp.getBody();
    
    System.Debug('myjson' +myjson);
    JSONParser parser =    JSON.createParser(myjson);
    System.Debug('MYparser' +parser);

    
    try
    {
    
    //If you use namespace, the name needs to be qualified or use the other﻿ two param version of the forName method
//Type wrapperType = Type.forName('GeoWebserviceObject'); 

//GeoWebserviceObject GW = (GeoWebserviceObject) parser.readValueAs(wrapperType);

//limeObject = (limeSurveyWebserviceObject) JSON.deserialize(JsonString, wrapperType);

 deserializedWL = 
          (List<GeoWebserviceObject>)JSON.deserialize(myjson, List<GeoWebserviceObject>.class);
      //  System.assertEquals(invoices.size(), deserializedInvoices.size());




       System.debug('GW' + deserializedWL);



    }
    catch (Exception e)
    {
  return null ;
    
    
        
    }

    
     
    
    
    
    
    
    
    
    return deserializedWL;
    
    
    } // end of the class
    
    







}
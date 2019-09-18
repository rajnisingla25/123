public with sharing class AjaxRespController 
{
    public String JSONString {get;set;}

    public AjaxRespController() {}

    /** invoked on an Ajax request */   
    public void retrieveData() 
    {
        // We need those parameters to work with JQuery DataTable.
        Map<String, String> params = ApexPages.currentPage().getParameters();
        for (String key : params.keySet())
        {
            system.debug('Key: ' + key + ', Value: ' + params.get(key));
        }
        List<Account> lstAaData = [SELECT Id, Name FROM Account LIMIT 10];

        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);

        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeNumberField('sEcho', Integer.valueOf(params.get('sEcho')));
        gen.writeNumberField('iTotalRecords', 14);
        gen.writeNumberField('iTotalDisplayRecords', 14);
        gen.writeFieldName('aaData');       
        gen.writeStartArray();
        for (Account acc : lstAaData)
        {       
            gen.writeStartArray();
            gen.writeString(acc.Name);
            gen.writeString(acc.Id);
            gen.writeEndArray();

        }

        gen.writeEndArray();
        gen.writeEndObject();

        JSONString = gen.getAsString();     
    }

}
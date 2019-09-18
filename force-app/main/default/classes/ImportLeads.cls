public with sharing class ImportLeads {
	public String Status { get;set;}
	public List<UsageRecord> UsageRecord { get;set;}
	
    public class UsageRecord {
        public String acct { get;set;}	
		public String aid { get;set;}	
		public String qty { get;set;}	
		public String rate{ get;set;}	
		public String name { get;set;}
        public String batchnumber{ get;set;}
	}

}
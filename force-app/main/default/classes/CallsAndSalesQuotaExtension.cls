//
// (c) 2015 Appirio, Inc.
//
// Controller Class Name: CallsAndSalesQuotaController
// For Apex Pages: agentAccountHighlightPanel, brokerAccountHighlightPanel
// Description: Here, we are displaying apex gauge charts that will help a sales manager to view trending information on sales and calls. The
// charts will display based on daily call (task) done by rep and quota define for the daily call. Also based on daily total amout for the orders
// that reps owns with the quota define with the target amount.
//
// 11th May 2015        Hemendra Singh Bhati   Original (Task # T-393569)
//
public class CallsAndSalesQuotaExtension {
    // Public Data Members.
    /******************************************
    public List<GaugeData> dailyCallsData { get; private set; }
    public List<GaugeData> dailySalesData { get; private set; }
    public List<GaugeData> monthlySalesData { get; private set; }
    public Boolean isUserFieldSalesRep { get; private set; }
    public Integer dailyCallsMaxValue { get; private set; }
    public Integer dailySalesMaxValue { get; private set; }
    public Integer monthlySalesMaxValue { get; private set; }
    public Integer dailyCallsSteps { get; private set; }
    public Integer dailySalesSteps { get; private set; }
    public Integer monthlySalesSteps { get; private set; }
    public Boolean showRedFlag { get; private set; }
    public Boolean showPageContent { get; private set; }
    public Integer theDaysPastDue { get; private set; }
    public Decimal thePastDueAmount { get; private set; }

    // Private Data Members.
    private Id theLoggedInUserId = UserInfo.getUserId();
    private Integer currentMonth = Date.today().month();
    private Integer currentYear = Date.today().year();
    private Map<Integer, String> allMonths = new Map<Integer, String> {
        1 => 'January',
        2 => 'February',
        3 => 'March',
        4 => 'April',
        5   => 'May',
        6 => 'June',
        7 => 'July',
        8   => 'August',
        9   => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'
    };
    private Map<Integer, Integer> totalDaysInMonth = new Map<Integer, Integer> {
        1 => 31,
        2 => Math.mod(currentYear, 4) == 0 ? 29 : 28,
        3 => 31,
        4 => 30,
        5   => 31,
        6 => 30,
        7 => 31,
        8   => 31,
        9   => 30,
        10 => 31,
        11 => 30,
        12 => 31
    };
    private Map<String, Integer> maximumValues = new Map<String, Integer>();
    private final String PROFILE_MOVE_AGENT_SALES_REP = 'Move Agent Sales Rep';
    private final String PROFILE_MOVE_BROKER_SALES_REP = 'Move Broker Sales Rep';
    private final String PROFILE_MOVE_FIELD_SALES_REP = 'Move Field Sales Rep';

    // The Constructor.
    public CallsAndSalesQuotaExtension(ApexPages.StandardController stdController) {
    // Determine Strategic Notes / Flag Status.
    showRedFlag = false;
    Account theLoadedAccount = (Account)stdController.getRecord();
    for(Account theAccount : [SELECT Customer_Care_Calls__c, Sales_Calls__c, Marketing_Emails__c, Agent_SLE__c, Exclusion_Notes__c
                              FROM Account WHERE Id = :theLoadedAccount.Id LIMIT 1]) {
      if(
        String.isNotBlank(theAccount.Customer_Care_Calls__c) ||
        String.isNotBlank(theAccount.Sales_Calls__c) ||
        String.isNotBlank(theAccount.Marketing_Emails__c) ||
        String.isNotBlank(theAccount.Agent_SLE__c) ||
        String.isNotBlank(theAccount.Exclusion_Notes__c)
      ) {
        showRedFlag = true;
      }
    }

    // Extracting Zuora Balance And Zuora Due Date Values.
    theDaysPastDue = 0;
    thePastDueAmount = 0;
    for(Zuora__ZInvoice__c theInvoice : [SELECT Id, Name, Zuora__Balance2__c, Zuora__DueDate__c FROM Zuora__ZInvoice__c
                                         WHERE Zuora__Account__c = :theLoadedAccount.Id ORDER BY CreatedDate DESC LIMIT 1]) {
      thePastDueAmount = theInvoice.Zuora__Balance2__c;
      if(theInvoice.Zuora__DueDate__c != null) {
        theDaysPastDue = Date.today().daysBetween(theInvoice.Zuora__DueDate__c);
        if(theDaysPastDue < 0) {
          theDaysPastDue = Math.abs(theDaysPastDue);
        }
        else {
          theDaysPastDue = 0;
        }
      }
    }

        // Gauge Charts Data Initialization.
        dailyCallsSteps = 0;
        dailySalesSteps = 0;
        monthlySalesSteps = 0;
        dailyCallsData = new List<GaugeData>();
        dailySalesData = new List<GaugeData>();
        monthlySalesData = new List<GaugeData>();

        // Extracting Gauge Charts Maximum Values.
        showPageContent = true;
        maximumValues = computeGaugeChartMaximumValues();
        if(maximumValues.size() == 0) {
          showPageContent = false;
            system.debug('TRACE: Error - No quota record found for the logged-in user.');
            return;
        }

        List<Profile> theLoggedInUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        if(theLoggedInUserProfile.size() == 0) {
            system.debug('TRACE: Error - User profile not found.');
            return;
        }

        String userProfileName = theLoggedInUserProfile[0].Name;
        String condition = ApexPages.currentPage().getParameters().get('condition');
        Boolean runforAll = true;
        system.debug('TRACE: userProfileName - ' + userProfileName);

        if(
            userProfileName.equalsIgnoreCase(PROFILE_MOVE_AGENT_SALES_REP) ||
            userProfileName.equalsIgnoreCase(PROFILE_MOVE_BROKER_SALES_REP) ||
            condition == '1' || runforAll 
        ) {
            isUserFieldSalesRep = false;

            // Gauge Charts Maximum Values.
            dailyCallsMaxValue = maximumValues.get('MaxDailyCalls');
            if(dailyCallsMaxValue < 5) {
              dailyCallsSteps = 1;
            }
            else {
              dailyCallsSteps = Integer.valueOf(dailyCallsMaxValue / 5);
            }
            system.debug('TRACE: dailyCallsSteps - ' + dailyCallsSteps);

            dailySalesMaxValue = maximumValues.get('MaxDailySales');
            if(dailySalesMaxValue < 5) {
              dailySalesSteps = 1;
            }
            else {
              dailySalesSteps = Integer.valueOf(dailySalesMaxValue / 5);
            }
            system.debug('TRACE: dailySalesSteps - ' + dailySalesSteps);

            // Extracting Gauge Data.
            dailyCallsData = extractDailyCallsData();
            dailySalesData = extractDailySalesData();
        }
        if(userProfileName.equalsIgnoreCase(PROFILE_MOVE_FIELD_SALES_REP) || condition == '2' || runforAll ) {
            isUserFieldSalesRep = true;

            // Gauge Charts Maximum Value.
            monthlySalesMaxValue = maximumValues.get('MaxMonthlySales');
            if(monthlySalesMaxValue < 5) {
              monthlySalesSteps = 1;
            }
            else {
              monthlySalesSteps = Integer.valueOf(monthlySalesMaxValue / 5);
            }
            system.debug('TRACE: monthlySalesSteps - ' + monthlySalesSteps);

            // Extracting Gauge Data.
            monthlySalesData = extractMonthlySalesData();
        }
        else {
          showPageContent = false;
        }
    }

    
  //@method      : extractDailyCallsData
  //@description : This method extracts all the calls processed by the logged-in user for the current day.
  //@params      : void
 // @returns     : List<GaugeData>
  
  private List<GaugeData> extractDailyCallsData() {
    List<GaugeData> dailyCallsData = new List<GaugeData>();
    Id theRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
        for(AggregateResult theResult : [SELECT count(Id)totalCallsMade FROM Task WHERE Type = 'Call' AND OwnerId = :theLoggedInUserId
                                                                         AND RecordTypeId = :theRecordTypeId]) {
            dailyCallsData.add(new GaugeData(
                'Calls',
                Integer.valueOf(theResult.get('totalCallsMade')) > dailyCallsMaxValue ? dailyCallsMaxValue : Integer.valueOf(theResult.get('totalCallsMade'))
            ));
    }
        system.debug('TRACE: dailyCallsData - ' + dailyCallsData);

    return dailyCallsData;
  }

    
  //@method      : extractDailySalesData
  //@description : This method extracts all the orders made by the logged-in user for the current day.
  //@params      : void
 // @returns     : List<GaugeData>
  
  private List<GaugeData> extractDailySalesData() {
    Decimal totalOrderAmount = 0.0;

    List<GaugeData> dailySalesData = new List<GaugeData>();
        for(Order theOrder : [SELECT TotalAmount FROM Order WHERE OwnerId = :theLoggedInUserId ]) {
            totalOrderAmount += theOrder.TotalAmount;
        }
        dailySalesData.add(new GaugeData(
            'Sales($)',
            Integer.valueOf(totalOrderAmount) > dailySalesMaxValue ? dailySalesMaxValue : Integer.valueOf(totalOrderAmount)
        ));
        system.debug('TRACE: dailySalesData - ' + dailySalesData);

    return dailySalesData;
  }

    
  //@method      : extractMonthlySalesData
  //@description : This method extracts all the orders made by the logged-in user for the current month.
  //@params      : void
  //@returns     : List<GaugeData>
  
  private List<GaugeData> extractMonthlySalesData() {
    Decimal totalOrderAmount = 0.0;
        Date currentMonthStartDate = Date.newinstance(currentYear, currentMonth, 1);
        Date currentMonthEndDate = Date.newinstance(currentYear, currentMonth, totalDaysInMonth.get(currentMonth));

    List<GaugeData> monthlySalesData = new List<GaugeData>();
        for(Order theOrder : [SELECT TotalAmount FROM Order WHERE CreatedById = :theLoggedInUserId AND
                                                    (CreatedDate >= :currentMonthStartDate AND CreatedDate <= :currentMonthEndDate)]) {
            totalOrderAmount += theOrder.TotalAmount;
        }
        monthlySalesData.add(new GaugeData(
            'Sales($)',
            Integer.valueOf(totalOrderAmount) > monthlySalesMaxValue ? monthlySalesMaxValue : Integer.valueOf(totalOrderAmount)
        ));
        system.debug('TRACE: monthlySalesData - ' + monthlySalesData);

    return monthlySalesData;
  }

    
  //@method      : computeGaugeChartMaximumValues
  //@description : This method computes daily calls/sales and monthly sales maximum values from quota record of the logged-in user for
                         : current day/month.
  //@params      : void
  //@returns     : Map<String, Integer>
  
  private Map<String, Integer> computeGaugeChartMaximumValues() {
    Map<String, Integer> maximumValues = new Map<String, Integer>();
    for(Quota__c theQuota : [SELECT Target_Activity_Daily__c, Target_Amount_Daily__c, Target_Amount_Monthly__c FROM Quota__c
                                                     WHERE Sales_Service_Rep__c = :theLoggedInUserId AND Period_Month__c = :allMonths.get(currentMonth)
                                                     AND Period_Year__c = :currentYear order by createdDate desc limit 1]) {
        maximumValues.put('MaxDailyCalls', Integer.valueOf(theQuota.Target_Activity_Daily__c));
        maximumValues.put('MaxDailySales', Integer.valueOf(theQuota.Target_Amount_Daily__c));
        maximumValues.put('MaxMonthlySales', Integer.valueOf(theQuota.Target_Amount_Monthly__c));
        }
        system.debug('TRACE: maximumValues - ' + maximumValues);
        return maximumValues;
  }

    // Inner Class To Club Gauge Data.
    public class GaugeData {
        public String name { get; set; }
        public Integer size { get; set; }

        public GaugeData(String name, Integer data) {
            this.name = name;
            this.size = data;
        }
    }
    *****************************/
}
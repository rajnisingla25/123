global class SortUserIdCountClass implements Comparable {

    public String userIds ;
    Public Decimal aleadcount{get;set;}

    public enum SORT_BY {
        LCount
        }

    //Variable to decide the member on which sorting should be performed
    public static SORT_BY sortBy = SORT_BY.LCount;

    global Integer compareTo(Object objToCompare) {
        
            return Integer.valueOf(aleadcount - ((SortUserIdCountClass)objToCompare).aleadcount);

        
    }
}
public class Pagination{
        public integer pagenumber{get;set;}
        public integer totalpages{get;set;}
        public integer pagesize{get;set;}
        public list<Asset> rowsList{get;set;}   
        public Pagination(list<Asset> allRows,integer itemsPerPage){
            if( allRows.size() != 0 ){
                pagenumber =1;
                pagesize = itemsPerPage;
                this.rowsList=allRows;
                totalpages= Integer.valueof(math.ceil((double)allRows.size()/(double)pagesize ));
            }    
            else{
                pagenumber = 0;
                totalpages = 0;
                pagesize = 1;
            }
        }
        public boolean gethasprevious(){
          return (pagenumber != 1 && totalpages != 0);
        }
        public boolean gethasnext(){
            return (pagenumber != totalpages);
        }
        public pagereference Previous(){
            if(gethasprevious())
                pagenumber--;
            return null;
        }
        public pagereference next(){
            if(gethasnext())
                pagenumber++;
            return null;
        }
        public list<Asset> getRecords(){
            list<Asset> paginatedRows = new list<Asset>();  
            if( rowsList != null && rowsList.size() != 0 ){
                for(integer counter2=(pagenumber-1)*pagesize;counter2<(math.min(pagenumber*pagesize,rowsList.size()));counter2++){
                    paginatedRows.add(rowsList.get(counter2));
                }
            }            
            return paginatedRows;
        }   
    }
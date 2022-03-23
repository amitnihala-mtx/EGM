public class ChatterHandler {

    public string recordid {get;set;}

    public ChatterHandler() {
        System.debug('Id in record : ' + ApexPages.currentPage().getParameters().get('id'));
        recordid = ApexPages.currentPage().getParameters().get('id');
    }
}
public with sharing class ProposalContractPDF
{
   
    public static final String FORM_HTML_START = '<HTML><BODY>';
    public static final String FORM_HTML_END = '</BODY></HTML>';

    public static void generateAccountPDF(Account account)
    {
        String pdfContent = '' + FORM_HTML_START;
        try
        {
            pdfContent = '' + FORM_HTML_START;
            pdfContent = pdfContent + '<H2>Account Information in PDF</H2>'; 
           
            //Dynamically grab all the fields to store in the PDF
            Map<String, Schema.SObjectType> sobjectSchemaMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult objDescribe = sobjectSchemaMap.get('Account').getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
           
            //Append each Field to the PDF
            for(Schema.SObjectField fieldDef : fieldMap.values())
            {
                Schema.Describefieldresult fieldDescResult = fieldDef.getDescribe();
                String name = fieldDescResult.getName();
                pdfContent = pdfContent + '<P>' + name + ': ' + account.get(name) + '</P>';
            }
            pdfContent = pdfContent + FORM_HTML_END;
        }catch(Exception e)
        {
            pdfContent = '' + FORM_HTML_START;
            pdfContent = pdfContent + '<P>THERE WAS AN ERROR GENERATING PDF: ' + e.getMessage() + '</P>';
            pdfContent = pdfContent + FORM_HTML_END;
        }
        attachPDF(account,pdfContent);
    }
   
    public static void attachPDF(Account account, String pdfContent)
    {
        try
        {
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = account.Id;
            attachmentPDF.Name = account.Name + '.pdf';
            attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
            insert attachmentPDF;
        }catch(Exception e)
        {
            account.addError(e.getMessage());
        }
    }
   
}
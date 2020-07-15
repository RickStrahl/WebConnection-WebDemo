************************************************************************
*PROCEDURE WebProcess
****************************
***  Function: Processes incoming Web Requests for WebProcess
***            requests. This function is called from the wwServer 
***            process.
***      Pass: loServer -   wwServer object reference
*************************************************************************
LPARAMETER loServer
LOCAL loProcess
PRIVATE Request, Response, Server, Session, Process
STORE NULL TO Request, Response, Server, Session, Process

#INCLUDE WCONNECT.H

loProcess = CREATEOBJECT("WebProcess", loServer)
loProcess.lShowRequestData = loServer.lShowRequestData

IF VARTYPE(loProcess)#"O"
   *** All we can do is return...
   RETURN .F.
ENDIF

*** Call the Process Method that handles the request
loProcess.Process()

*** Explicitly force process class to release
loProcess.Dispose()

RETURN

*************************************************************
DEFINE CLASS WebProcess AS WWC_PROCESS
*************************************************************

*** Response class used - override as needed
cResponseClass = [WWC_PAGERESPONSE]

*** Default for page script processing if no method exists
*** 1 - MVC Template (ExpandTemplate()) 
*** 2 - Web Control Framework Pages
*** 3 - MVC Script (ExpandScript())
nPageScriptMode = 3

*!* cAuthenticationMode = "UserSecurity"  && `Basic` is default


*** ADD PROCESS CLASS EXTENSIONS ABOVE - DO NOT MOVE THIS LINE ***


#IF .F.
* Intellisense for THIS
LOCAL THIS as WebProcess OF WebProcess.prg
#ENDIF
 
*********************************************************************
* Function WebProcess :: OnProcessInit
************************************
*** If you need to hook up generic functionality that occurs on
*** every hit against this process class , implement this method.
*********************************************************************
FUNCTION OnProcessInit

*!* LOCAL lcScriptName, llForceLogin
*!*	THIS.InitSession("MyApp")
*!*
*!*	lcScriptName = LOWER(JUSTFNAME(Request.GetPhysicalPath()))
*!*	llIgnoreLoginRequest = INLIST(lcScriptName,"default","login","logout")
*!*
*!*	IF !THIS.Authenticate("any","",llIgnoreLoginRequest) 
*!*	   IF !llIgnoreLoginRequest
*!*		  RETURN .F.
*!*	   ENDIF
*!*	ENDIF

*** Explicitly specify that pages should encode to UTF-8 
*** Assume all form and query request data is UTF-8
Response.Encoding = "UTF8"
Request.lUtf8Encoding = .T.


*** Add CORS header to allow cross-site access from other domains/mobile devices on Ajax calls
*!* Response.AppendHeader("Access-Control-Allow-Origin","*")
*!* Response.AppendHeader("Access-Control-Allow-Origin",Request.ServerVariables("HTTP_ORIGIN"))
*!* Response.AppendHeader("Access-Control-Allow-Methods","POST, GET, DELETE, PUT, OPTIONS")
*!* Response.AppendHeader("Access-Control-Allow-Headers","Content-Type, *")
*!* *** Allow cookies and auth headers
*!* Response.AppendHeader("Access-Control-Allow-Credentials","true")
*!* 
*!* *** CORS headers are requested with OPTION by XHR clients. OPTIONS returns no content
*!*	lcVerb = Request.GetHttpVerb()
*!*	IF (lcVerb == "OPTIONS")
*!*	   *** Just exit with CORS headers set
*!*	   *** Required to make CORS work from Mobile devices
*!*	   RETURN .F.
*!*	ENDIF   


RETURN .T.
ENDFUNC




*********************************************************************
FUNCTION TestPage()
************************

THIS.StandardPage("Hello World from the WebProcess Process Class",;
                  "If you got here, everything is working fine.<p>" + ;
                  "Server Time: <b>" + TIME()+ "</b>")
                  
ENDFUNC
* EOF TestPage


*********************************************************************
FUNCTION HelloScript()
************************
PRIVATE poError 

*** Configure a model and pass it into the script
*** Use this to display an ErrorDisplay object
poError = CREATEOBJECT("HtmlErrorDisplayConfig")
poError.Message = "Welcome from the " + this.Class + " class, using MVC scripting."
poError.Icon = "info"

*** Run a query and pass the data to the script
SELECT TOP 10 * FROM wwRequestLog  ;
INTO CURSOR TRequests ;
ORDER BY Time Desc

*** Render HelloScript page template
Response.ExpandScript()

USE IN TRequests
ENDFUNC
* EOF HelloScript


*************************************************************
*** PUT YOUR OWN CUSTOM METHODS HERE                      
*** 
*** Any method added to this class becomes accessible
*** as an HTTP endpoint with MethodName.Extension where
*** .Extension is your scriptmap. If your scriptmap is .rs
*** and you have a function called Helloworld your
*** endpoint handler becomes HelloWorld.rs
*************************************************************

************************************************************************
*  CustomerList
****************************************
FUNCTION CustomerList()

* Make sure Customers.dbf is PATH:   \wconnect\Samples\wwdemo

*** Retrieve the customer via Querystring parameter from the URL
lcCompany = Request.Params("Company")

*** Run a query with company as parameter
SELECT HREF([ShowCustomer.wp?id=] + id,company) as Company, ;
       FirstName + LastName as Customer_Name, ;
       ShortDate(Entered,1) as Entered ;
   FROM Customers ;
   WHERE UPPER(Company) = UPPER(lcCompany) ;
   ORDER BY Company ;
   INTO CURSOR TQuery

lnRecCount = _Tally   

* **Helper to generate templated HTML Header
Response.Write(this.PageHeaderTemplate("Customer List"))

*** Display the dynamic record count as part of the header
TEXT TO lcHtml TEXTMERGE NOSHOW
<h3 class="page-header-text">
   <i class='fa fa-list'></i> Customer List
   <span class='badge badge-info badge-super'><<TRANSFORM(lnRecCount)>></span>
</h3> 

<!-- THIS CODE SHOWS THE INPUT FORM  THAT POSTS BACK TO THIS SAME PAGE -->
<form action="customerlist.wp" method="POST">

<div class="input-group mt-4 mb-3">
  <div class="input-group-prepend">
   <span class="input-group-text">
   <i class="fas fa-search"></i>&nbsp; Company</span>
  </div>
  <input type="text" name="Company" 
         class="form-control" 
         placeholder="filter by company"
         value="<<lcCompany>>"
   />
  <div class="input-group-append">      
      <button type="submit" name="btnSearch" class="btn btn-primary mt-0" AccessKey="S">
         Search...
      </button>	      
   </div>
</div>

</form>
ENDTEXT
Response.Write(lcHtml)


IF lnRecCount > 0
	lcHtml = HtmlDataGrid("TQuery")
ELSE
	lcHtml = "<div class='alert alert-warning'><i class='fa fa-warning'></i>" + ;
            "No matching customers found for <b>'"  +  lcCompany + "'</b>.</div>"	
ENDIF

Response.Write(lcHtml)

* **Helper to generate templated HTML Footer
Response.Write(this.PageFooterTemplate())

ENDFUNC


************************************************************************
*  ShowCustomer
****************************************
FUNCTION ShowCustomer()
LOCAL lcHtml, lcId

lcId = Request.Params("id")


SELECT * FROM Customers ;
   WHERE id = lcId ;
   INTO CURSOR TQuery

IF _Tally < 1
   *** Create an error page
   this.ErrorMsg("Invalid Customer Id",;
   "The customer couldn't be retrieved. Make sure the URL is correct " + ;
   "and points at a valid customer record.hr/>Please return to the <a href='Customerlist.wp'>customer list</a>...")
   RETURN 
ENDIF

*** Helper to generate templated HTML Header
Response.Write(this.PageHeaderTemplate("Customer List"))


TEXT TO lcHtml TEXTMERGE NOSHOW
<div class="btn-group float-right btn-group-sm" aria-label="Basic example">
  <a class="btn btn-secondary" href="EditCustomer.wp?id=<<lcId>>"><i class="fas fa-edit"></i> Edit</a>
  <a class="btn btn-success" href="CustomerList.wp"><i class="fas fa-list"></i> Customers</a>  
</div>


<div class="page-header-text">
   <i class='fa fa-user'></i> <<Company>>
</div>

ENDTEXT
Response.Write(lcHtml)

*** Render the Record into a table
loConfig = CREATEOBJECT("HtmlRecordConfig")
loConfig.Width = "700px"

*loConfig.HeaderCssClass = "col-sm-3 my-record-header"
*loConfig.ItemCssClass = "col-sm-7"

*** Create columns manually for each field
loCol = CREATEOBJECT("HtmlRecordColumn","Company")
loConfig.AddColumn(loCol)

loCol = CREATEOBJECT("HtmlRecordColumn","FirstName + ' ' + LastName","Name")
loConfig.AddColumn(loCol)

loCol = CREATEOBJECT("HtmlRecordColumn","Address")
loCol.FieldType="M"
loConfig.AddColumn(loCol)

loCol = CREATEOBJECT("HtmlRecordColumn","Email")
loConfig.AddColumn(loCol)

loCol = CREATEOBJECT("HtmlRecordColumn","BillRate","Bill Rate")
loCol.Format = "$$,$$$.99"
loCol.FieldType = "N"
loConfig.AddColumn(loCol)

loCol = CREATEOBJECT("HtmlRecordColumn",[ShortDate(Entered,2)],"Entered")
loCol.FieldType = "C"
loConfig.AddColumn(loCol)

lcHtml = HtmlRecord("TQuery",loConfig)
Response.Write(lcHtml)

Response.Write(this.PageFooterTemplate())

ENDFUNC

****************************************************
* EditCustomer
******************************
FUNCTION EditCustomer()
PRIVATE pcErrorMsg, poError, pcId

pcErrorMsg = ""
poError = CREATEOBJECT("HtmlErrorDisplayConfig")

pcId = Request.Params("Id")

IF !USED("Customers")
   USE Customers IN 0
ENDIF
SELECT Customers

IF !EMPTY(pcId)
   LOCATE FOR Id=pcId
ELSE
   GO BOTTOM 
   SKIP 
ENDIF

PRIVATE poCustomer
SCATTER NAME poCustomer Memo


IF Request.IsPostBack()
   *** Unbind all matching fields into properties of this object
   loErrors = Request.UnbindFormVars(poCustomer)
   
   IF (loErrors.Count > 0)
	      pcErrorMsg = "There are binding errors." + loErrors.ToHtml(.t.)
   ENDIF


   *** Validation goes here     
   IF EMPTY(poCustomer.Id)
      poCustomer.Id = SYS(2015)
      APPEND blank
   ENDIF
   IF !EMPTY(poCustomer.Email) AND AT("@",poCustomer.Email) = 0
      loErrors.AddError("Invalid Email Address","Email")
   ENDIF
   IF EMPTY(poCustomer.Company)
      loErrors.AddError("Company cannot be left blank","Company")
   ENDIF
   IF poCustomer.Entered < {^2000-01-01 :}
      loErrors.AddError("Entered can't be before the year 2000","Entered")
   ENDIF

   GATHER NAME poCustomer MEMO 
   
   IF loErrors.Count = 0 AND EMPTY(pcErrorMsg)
	   poError.Message = "Customer info saved."   	
	   Response.AppendHeader("refresh","3;url=CustomerList.wp")
   ELSE          
       poError.Message = "Please correct the following errors..."
       poError.Errors = loErrors
       * poError.Message =  loErrors.ToHtml()
       
   ENDIF
ENDIF

*** Render EditCustomer.wp
Response.ExpandScript()

ENDFUNC

ENDDEFINE
using Microsoft.AspNetCore.Mvc;
using OrderManager.Web.Constants;
using OrderManager.Web.SqlConnection;

namespace OrderManager.Web.Areas.Store.Controllers;

[Area(AreaNames.Store)]
[SqlConnectionContext(ConnectionStringNames.CustomerConnectionString)]
[Route("/products")]
public class ProductController : Controller { }
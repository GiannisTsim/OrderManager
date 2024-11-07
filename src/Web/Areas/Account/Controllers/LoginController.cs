using Microsoft.AspNetCore.Mvc;
using OrderManager.Web.Constants;

namespace OrderManager.Web.Areas.Account.Controllers;

[Area(AreaNames.Account)]
[Route("/account/login")]
public class LoginController : Controller
{
    private readonly ILogger<LoginController> _logger;

    public LoginController(ILogger<LoginController> logger)
    {
        _logger = logger;
    }

    public IActionResult Login()
    {
        // HttpContext.SignInAsync
        return View();
    }
}
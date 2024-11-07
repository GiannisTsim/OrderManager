using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Web.Constants;
using OrderManager.Web.SqlConnection;

namespace OrderManager.Web.Areas.Administration.Controllers;

[Area(AreaNames.Administration)]
[SqlConnectionContext(ConnectionStringNames.AdminConnectionString)]
[Route("/administration/retailers/{retailerNo:int}/branches")]
public class RetailerBranchController : Controller
{
    private readonly IRetailerBranchRepository _retailerBranchRepository;
    private readonly IStringLocalizer<RetailerBranchController> _localizer;

    public RetailerBranchController(
        IRetailerBranchRepository retailerBranchRepository,
        IStringLocalizer<RetailerBranchController> localizer)
    {
        _retailerBranchRepository = retailerBranchRepository;
        _localizer = localizer;
    }

    [HttpGet]
    public async Task<IActionResult> Index(
        [FromRoute] int retailerNo,
        [FromQuery] string? searchTerm,
        [FromQuery] string? sortColumn,
        [FromQuery] bool isDescending = false,
        [FromQuery] int pageNo = 1,
        [FromQuery] int pageSize = 5)
    {
        throw new NotImplementedException();
        // var retailerTask = _retailerBranchRepository.GetAsync
        //     (searchTerm, sortColumn, isDescending, pageNo, pageSize);
        // var totalResultCountTask = _retailerBranchRepository.GetTotalResultCountAsync(searchTerm);
        //
        // var viewModel = new IndexViewModel
        // {
        //     Retailers = (await retailerTask).Select
        //     (
        //         (retailer, index) => new IndexViewModel.RetailerViewItem
        //         (
        //             (pageNo - 1) * pageSize + index + 1,
        //             retailer.RetailerNo,
        //             retailer.UpdatedDtm,
        //             retailer.TaxId,
        //             retailer.Name,
        //             retailer.IsObsolete,
        //             retailer.BranchCount
        //         )
        //     ),
        //     SearchTerm = searchTerm,
        //     TotalResultCount = await totalResultCountTask,
        //     PageNo = pageNo,
        //     PageSize = pageSize
        // };
        //
        // ModelState.Remove(nameof(searchTerm));
        //
        // return View(viewModel);
    }

    // [HttpGet("{branchNo:int}")]
    // public async Task<IActionResult> Details([FromRoute] int retailerNo, [FromRoute] int branchNo)
    // {
    // }
    //
    // [HttpGet("add")]
    // [ModelStateImport]
    // public IActionResult Add()
    // {
    // }
    //
    // [HttpPost("add")]
    // [ModelStateExport]
    // public async Task<IActionResult> Add()
    // {
    //     throw new NotImplementedException();
    // }
    //
    // [HttpGet("{branchNo:int}/modify")]
    // [ModelStateImport]
    // public async Task<IActionResult> Modify()
    // {
    //     throw new NotImplementedException();
    // }
    //
    // [HttpPost("{branchNo:int}/modify")]
    // [ModelStateExport]
    // public async Task<IActionResult> Modify()
    // {
    //     throw new NotImplementedException();
    // }
    //
    // [HttpGet("{branchNo:int}/obsolete")]
    // public async Task<IActionResult> Obsolete()
    // {
    //     throw new NotImplementedException();
    // }
    //
    //
    // [HttpPost("{branchNo:int}/obsolete")]
    // public async Task<IActionResult> Obsolete()
    // {
    //     throw new NotImplementedException();
    // }
    //
    // [HttpPost("validate/name")]
    // [IgnoreAntiforgeryToken]
    // public async Task<IActionResult> ValidateName(string name)
    // {
    //     throw new NotImplementedException();
    // }
}
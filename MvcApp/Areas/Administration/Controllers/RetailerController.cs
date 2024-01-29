using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Exceptions.Retailer;
using OrderManager.Core.Models.Retailer;
using OrderManager.MvcApp.Areas.Administration.Models.Retailer;
using OrderManager.MvcApp.Filters;

namespace OrderManager.MvcApp.Areas.Administration.Controllers;

[Area("Administration")]
[Route("/administration/retailers")]
public class RetailerController : Controller
{
    private readonly IRetailerRepository _retailerRepository;
    private readonly IStringLocalizer<RetailerController> _localizer;

    public RetailerController(
        IRetailerRepository retailerRepository,
        IStringLocalizer<RetailerController> localizer
    )
    {
        _retailerRepository = retailerRepository;
        _localizer = localizer;
    }

    [HttpGet]
    public async Task<IActionResult> Index(
        [FromQuery] string? searchTerm,
        [FromQuery] string? sortColumn,
        [FromQuery] bool isDescending = false,
        [FromQuery] int pageNo = 1,
        [FromQuery] int pageSize = 5
    )
    {
        var retailerTask = _retailerRepository.GetAsync
            (searchTerm, sortColumn, isDescending, pageNo, pageSize);
        var totalResultCountTask = _retailerRepository.GetTotalResultCountAsync(searchTerm);

        var viewModel = new IndexViewModel
        {
            Retailers = (await retailerTask).Select
            (
                (retailer, index) => new IndexViewModel.Retailer
                (
                    (pageNo - 1) * pageSize + index + 1,
                    retailer.RetailerNo,
                    retailer.UpdatedDtm,
                    retailer.VatId,
                    retailer.Name,
                    retailer.IsObsolete,
                    retailer.BranchCount
                )
            ),
            SearchTerm = searchTerm,
            TotalResultCount = await totalResultCountTask,
            PageNo = pageNo,
            PageSize = pageSize
        };

        ModelState.Remove(nameof(searchTerm));

        return View(viewModel);
    }

    [HttpGet("{retailerNo:int}")]
    public async Task<IActionResult> Details([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var viewModel = new DetailsViewModel(retailer);
        return View(viewModel);
    }

    [HttpGet("add")]
    public IActionResult Add()
    {
        var viewModel = new AddViewModel(new AddInputModel { Name = null, VatId = null });
        return View(viewModel);
    }

    [HttpPost("add")]
    [TestActionFilter]
    [TestExceptionFilter]
    // [TestExceptionFilter<RetailerDuplicateVatIdException>]
    // [TypeFilter(typeof(TempDataExceptionFilter<RetailerDuplicateVatIdException>), Arguments = ["", "foo"])]
    [ModelStateErrorFromException<RetailerDuplicateVatIdException>(PropagateException = true)]
    [ModelStateErrorFromException<RetailerDuplicateNameException>]
    // [TempDataExceptionFilter<RetailerDuplicateVatIdException>(Message = "fooMessage")]
    // [TempDataExceptionFilter<RetailerDuplicateNameException>(Message = "barMessage")]
    public async Task<IActionResult> Add(
        [FromForm, Bind(Prefix = nameof(AddViewModel.AddInputModel))]
        AddInputModel inputModel
    )
    {
        if (!ModelState.IsValid) return View();

        // try
        // {
        var command = new RetailerAddCommand
        (
            inputModel.VatId ?? throw new ArgumentNullException(),
            inputModel.Name ?? throw new ArgumentNullException()
        );
        var retailerNo = await _retailerRepository.AddAsync(command);
        return RedirectToAction(nameof(Details), new { RetailerNo = retailerNo });
        // }
        // catch (RetailerDuplicateVatIdException)
        // {
        //     ModelState.AddModelError
        //     (
        //         $"{nameof(AddViewModel.AddInputModel)}.{nameof(AddViewModel.AddInputModel.VatId)}",
        //         localizer["RetailerDuplicateVatId"]
        //     );
        //     return View();
        // }
        // catch (RetailerDuplicateNameException)
        // {
        //     ModelState.AddModelError
        //     (
        //         $"{nameof(AddViewModel.AddInputModel)}.{nameof(AddViewModel.AddInputModel.Name)}",
        //         localizer["RetailerDuplicateName"]
        //     );
        //     return View();
        // }
    }

    [HttpGet("{retailerNo:int}/modify")]
    public async Task<IActionResult> Modify([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindByRetailerNoAsync((int)retailerNo);
        if (retailer == null) return NotFound();

        var viewModel = new ModifyViewModel
        (
            retailer,
            new ModifyInputModel
            {
                UpdatedDtm = retailer.UpdatedDtm,
                VatId = retailer.VatId,
                Name = retailer.Name
            }
        );
        return View(viewModel);
    }

    [HttpPost("{retailerNo:int}/modify")]
    public async Task<IActionResult> Modify(
        [FromRoute] int retailerNo,
        [FromForm, Bind(Prefix = nameof(ModifyViewModel.ModifyInputModel))]
        ModifyInputModel inputModel
    )
    {
        if (!ModelState.IsValid)
        {
            var retailer = await _retailerRepository.FindByRetailerNoAsync(retailerNo);
            if (retailer == null) return NotFound();

            var viewModel = new ModifyViewModel
            (
                retailer,
                new ModifyInputModel
                {
                    UpdatedDtm = retailer.UpdatedDtm,
                    VatId = retailer.VatId,
                    Name = retailer.Name
                }
            );
            return View(viewModel);
        }

        var command = new RetailerModifyCommand
        (
            retailerNo,
            inputModel.UpdatedDtm ?? throw new ArgumentNullException(),
            inputModel.VatId ?? throw new ArgumentNullException(),
            inputModel.Name ?? throw new ArgumentNullException()
        );
        await _retailerRepository.ModifyAsync(command);
        return RedirectToAction(nameof(Details), new { retailerNo });
    }

    [HttpGet("{retailerNo:int}/obsolete")]
    public async Task<IActionResult> Obsolete([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var model = new ObsoleteViewModel
        (
            retailer,
            new ObsoleteInputModel
            {
                UpdatedDtm = retailer.UpdatedDtm
            }
        );
        return View(model);
    }


    [HttpPost("{retailerNo:int}/obsolete")]
    public async Task<IActionResult> Obsolete(
        [FromRoute] int retailerNo,
        [FromForm, Bind(Prefix = nameof(ObsoleteViewModel.ObsoleteInputModel))]
        ObsoleteInputModel model
    )
    {
        if (!ModelState.IsValid)
        {
            return RedirectToAction(nameof(Details), new { retailerNo });
        }

        var retailerObsolete = new RetailerObsoleteCommand
        (
            retailerNo,
            model.UpdatedDtm ?? throw new ArgumentNullException(nameof(model.UpdatedDtm))
        );
        await _retailerRepository.ObsoleteAsync(retailerObsolete);
        return RedirectToAction(nameof(Index));
    }

    [HttpPost("validate/vatId")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> ValidateVatId(string vatId)
    {
        return await _retailerRepository.VerifyExistenceByVatIdAsync(vatId)
            ? Json(_localizer["RetailerDuplicateVatId"].Value)
            : Json(true);
    }

    [HttpPost("validate/name")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> ValidateName(string name)
    {
        return await _retailerRepository.VerifyExistenceByNameAsync(name)
            ? Json(_localizer["RetailerDuplicateName"].Value)
            : Json(true);
    }
}
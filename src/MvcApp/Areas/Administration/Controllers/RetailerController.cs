using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Exceptions;
using OrderManager.Core.Retailer.Models;
using OrderManager.MvcApp.Areas.Administration.Models.Retailer;
using OrderManager.MvcApp.Constants;
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
                (retailer, index) => new IndexViewModel.RetailerViewItem
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
    [ModelStateImport]
    public IActionResult Add()
    {
        var viewModel = new AddViewModel { AddInput = new AddViewModel.AddInputModel { Name = null, VatId = null } };
        return View(viewModel);
    }

    [HttpPost("add")]
    [ModelStateExport]
    public async Task<IActionResult> Add(
        [FromForm, Bind(Prefix = nameof(AddViewModel.AddInput))]
        AddViewModel.AddInputModel addInput
    )
    {
        if (!ModelState.IsValid) return RedirectToAction();

        try
        {
            var addCommand = new RetailerAddCommand(addInput.VatId!, addInput.Name!);
            var retailerNo = await _retailerRepository.AddAsync(addCommand);
            TempData[TempDataKeys.StatusMessageSuccess] = _localizer["RetailerAddSuccess"].Value;
            return RedirectToAction(nameof(Details), new { RetailerNo = retailerNo });
        }
        catch (RetailerDuplicateVatIdException)
        {
            ModelState.AddModelError
            (
                $"{nameof(AddViewModel.AddInput)}.{nameof(AddViewModel.AddInput.VatId)}",
                _localizer["RetailerDuplicateVatId"]
            );
            return RedirectToAction();
        }
        catch (RetailerDuplicateNameException)
        {
            ModelState.AddModelError
            (
                $"{nameof(AddViewModel.AddInput)}.{nameof(AddViewModel.AddInput.Name)}",
                _localizer["RetailerDuplicateName"]
            );
            return RedirectToAction();
        }
    }

    [HttpGet("{retailerNo:int}/modify")]
    [ModelStateImport]
    public async Task<IActionResult> Modify([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var viewModel = new ModifyViewModel
        {
            Retailer = retailer,
            ModifyInput = new ModifyViewModel.ModifyInputModel
            {
                UpdatedDtm = retailer.UpdatedDtm,
                VatId = retailer.VatId,
                Name = retailer.Name
            }
        };
        return View(viewModel);
    }

    [HttpPost("{retailerNo:int}/modify")]
    [ModelStateExport]
    public async Task<IActionResult> Modify(
        [FromRoute] int retailerNo,
        [FromForm, Bind(Prefix = nameof(ModifyViewModel.ModifyInput))]
        ModifyViewModel.ModifyInputModel modifyInput
    )
    {
        if (!ModelState.IsValid) return RedirectToAction();

        try
        {
            var modifyCommand = new RetailerModifyCommand
            (
                retailerNo,
                (DateTimeOffset)modifyInput.UpdatedDtm!,
                modifyInput.VatId!,
                modifyInput.Name!
            );
            await _retailerRepository.ModifyAsync(modifyCommand);
            TempData[TempDataKeys.StatusMessageSuccess] = _localizer["RetailerModifySuccess"].Value;
            return RedirectToAction(nameof(Details), new { retailerNo });
        }
        catch (RetailerDuplicateVatIdException)
        {
            ModelState.AddModelError
            (
                $"{nameof(ModifyViewModel.ModifyInput)}.{nameof(ModifyViewModel.ModifyInput.VatId)}",
                _localizer["RetailerDuplicateVatId"]
            );
            return RedirectToAction();
        }
        catch (RetailerDuplicateNameException)
        {
            ModelState.AddModelError
            (
                $"{nameof(ModifyViewModel.ModifyInput)}.{nameof(ModifyViewModel.ModifyInput.Name)}",
                _localizer["RetailerDuplicateName"]
            );
            return RedirectToAction();
        }
        catch (RetailerNotFoundException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer["RetailerNotFound"].Value;
            return RedirectToAction(nameof(Index));
        }
        catch (RetailerCurrencyLostException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer["RetailerCurrencyLost"].Value;
            return RedirectToAction(nameof(Details), new { retailerNo });
        }
    }

    [HttpGet("{retailerNo:int}/obsolete")]
    public async Task<IActionResult> Obsolete([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var model = new ObsoleteViewModel
        {
            Retailer = retailer,
            ObsoleteInput = new ObsoleteViewModel.ObsoleteInputModel
            {
                UpdatedDtm = retailer.UpdatedDtm
            }
        };
        return View(model);
    }


    [HttpPost("{retailerNo:int}/obsolete")]
    public async Task<IActionResult> Obsolete(
        [FromRoute] int retailerNo,
        [FromForm, Bind(Prefix = nameof(ObsoleteViewModel.ObsoleteInput))]
        ObsoleteViewModel.ObsoleteInputModel obsoleteInput
    )
    {
        if (!ModelState.IsValid) return RedirectToAction(nameof(Details), new { retailerNo });

        try
        {
            var obsoleteCommand = new RetailerObsoleteCommand(retailerNo, (DateTimeOffset)obsoleteInput.UpdatedDtm!);
            await _retailerRepository.ObsoleteAsync(obsoleteCommand);
            return RedirectToAction(nameof(Index));
        }
        catch (RetailerNotFoundException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer["RetailerNotFound"].Value;
            return RedirectToAction(nameof(Index));
        }
        catch (RetailerCurrencyLostException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer["RetailerCurrencyLost"].Value;
            return RedirectToAction(nameof(Details), new { retailerNo });
        }
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
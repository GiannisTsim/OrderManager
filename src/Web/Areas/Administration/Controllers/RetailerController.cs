using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Commands.Retailer;
using OrderManager.Core.Retailer.Exceptions.Retailer;
using OrderManager.Localization.Resources.Retailer;
using OrderManager.Web.Areas.Administration.Models.Retailer;
using OrderManager.Web.Constants;
using OrderManager.Web.Filters;
using OrderManager.Web.SqlConnection;

namespace OrderManager.Web.Areas.Administration.Controllers;

[Area(AreaNames.Administration)]
[SqlConnectionContext(ConnectionStringNames.AdminConnectionString)]
[Route("/administration/retailers")]
public class RetailerController : Controller
{
    private readonly IRetailerRepository _retailerRepository;
    private readonly IStringLocalizer<RetailerResource> _localizer;

    public RetailerController(
        IRetailerRepository retailerRepository,
        IStringLocalizer<RetailerResource> localizer)
    {
        _retailerRepository = retailerRepository;
        _localizer = localizer;
    }

    // TODO: Implement sort functionality
    [HttpGet]
    public async Task<IActionResult> Index(
        [FromQuery] string? searchTerm,
        [FromQuery] string? sortColumn,
        [FromQuery] bool isDescending = false,
        [FromQuery] int pageNo = 1,
        [FromQuery] int pageSize = 5)
    {
        var retailerTask = _retailerRepository.GetDetailsAsync(searchTerm, sortColumn, isDescending, pageNo, pageSize);
        var totalResultCountTask = _retailerRepository.GetTotalResultCountAsync(searchTerm);
        await Task.WhenAll([retailerTask, totalResultCountTask]);

        var model = new IndexViewModel
        {
            Retailers = retailerTask.Result.Select
            (
                (retailer, index) => new IndexViewModel.RetailerViewItem
                {
                    OrdinalNo = (pageNo - 1) * pageSize + index + 1,
                    RetailerNo = retailer.RetailerNo,
                    UpdatedDtm = retailer.UpdatedDtm,
                    TaxId = retailer.TaxId,
                    Name = retailer.Name,
                    IsObsolete = retailer.IsObsolete,
                    BranchCount = retailer.BranchCount
                }
            ),
            SearchTerm = searchTerm,
            TotalResultCount = totalResultCountTask.Result,
            PageNo = pageNo,
            PageSize = pageSize
        };

        ModelState.Remove(nameof(searchTerm));

        return View(model);
    }

    [HttpGet("{retailerNo:int}")]
    public async Task<IActionResult> Details([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindDetailsByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var model = new DetailsViewModel(retailer);
        return View(model);
    }

    [HttpGet("add")]
    [ModelStateImport]
    public IActionResult Add([FromQuery] string? cancellationReturnUrl)
    {
        var model = new AddViewModel
        {
            AddInput = new AddViewModel.AddInputModel
            {
                Name = null,
                TaxId = null,
                CancellationReturnUrl = cancellationReturnUrl ?? Url.Action(nameof(Index))!
            }
        };
        return View(model);
    }

    [HttpPost("add")]
    [ModelStateExport]
    public async Task<IActionResult> Add([FromForm] AddViewModel.AddInputModel model)
    {
        if (!ModelState.IsValid) return RedirectToAction();

        try
        {
            var command = new RetailerAddCommand(model.TaxId, model.Name);
            var retailerNo = await _retailerRepository.AddAsync(command);
            TempData[TempDataKeys.StatusMessageSuccess] = _localizer[RetailerResourceKeys.Retailer.AddSuccess].Value;
            return RedirectToAction(nameof(Details), new { RetailerNo = retailerNo });
        }
        catch (RetailerDuplicateTaxIdException)
        {
            ModelState.AddModelError(nameof(model.TaxId), _localizer[RetailerResourceKeys.Retailer.DuplicateTaxId]);
            return RedirectToAction();
        }
        catch (RetailerDuplicateNameException)
        {
            ModelState.AddModelError(nameof(model.Name), _localizer[RetailerResourceKeys.Retailer.DuplicateName]);
            return RedirectToAction();
        }
    }

    [HttpGet("{retailerNo:int}/modify")]
    [ModelStateImport]
    public async Task<IActionResult> Modify([FromRoute] int retailerNo, [FromQuery] string? cancellationReturnUrl)
    {
        var retailer = await _retailerRepository.FindDetailsByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var model = new ModifyViewModel
        {
            Retailer = retailer,
            ModifyInput = new ModifyViewModel.ModifyInputModel
            {
                RetailerNo = retailer.RetailerNo,
                UpdatedDtm = retailer.UpdatedDtm,
                TaxId = retailer.TaxId,
                Name = retailer.Name,
                CancellationReturnUrl = cancellationReturnUrl ?? Url.Action(nameof(Index))!
            }
        };
        return View(model);
    }

    [HttpPost("{retailerNo:int}/modify")]
    [ModelStateExport]
    public async Task<IActionResult> Modify([FromForm] ModifyViewModel.ModifyInputModel model)
    {
        if (!ModelState.IsValid) return RedirectToAction();

        try
        {
            var command = new RetailerModifyCommand(model.RetailerNo, model.UpdatedDtm, model.TaxId, model.Name);
            await _retailerRepository.ModifyAsync(command);
            TempData[TempDataKeys.StatusMessageSuccess] = _localizer[RetailerResourceKeys.Retailer.ModifySuccess].Value;
            return RedirectToAction(nameof(Details), new { model.RetailerNo });
        }
        catch (RetailerDuplicateTaxIdException)
        {
            ModelState.AddModelError(nameof(model.TaxId), _localizer[RetailerResourceKeys.Retailer.DuplicateTaxId]);
            return RedirectToAction();
        }
        catch (RetailerDuplicateNameException)
        {
            ModelState.AddModelError(nameof(model.Name), _localizer[RetailerResourceKeys.Retailer.DuplicateName]);
            return RedirectToAction();
        }
        catch (RetailerNotFoundException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer[RetailerResourceKeys.Retailer.NotFound].Value;
            return RedirectToAction(nameof(Index));
        }
        catch (RetailerCurrencyLostException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer[RetailerResourceKeys.Retailer.CurrencyLost].Value;
            return RedirectToAction(nameof(Details), new { model.RetailerNo });
        }
    }

    [HttpGet("{retailerNo:int}/obsolete")]
    public async Task<IActionResult> Obsolete([FromRoute] int retailerNo)
    {
        var retailer = await _retailerRepository.FindDetailsByRetailerNoAsync(retailerNo);
        if (retailer == null) return NotFound();

        var model = new ObsoleteViewModel
        {
            Retailer = retailer,
            ObsoleteInput = new ObsoleteViewModel.ObsoleteInputModel
            {
                RetailerNo = retailer.RetailerNo, UpdatedDtm = retailer.UpdatedDtm
            }
        };
        return View(model);
    }


    [HttpPost("{retailerNo:int}/obsolete")]
    public async Task<IActionResult> Obsolete([FromForm] ObsoleteViewModel.ObsoleteInputModel model)
    {
        if (!ModelState.IsValid) return RedirectToAction(nameof(Details), new { model.RetailerNo });

        try
        {
            var command = new RetailerObsoleteCommand(model.RetailerNo, model.UpdatedDtm);
            await _retailerRepository.ObsoleteAsync(command);
            return RedirectToAction(nameof(Index));
        }
        catch (RetailerNotFoundException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer[RetailerResourceKeys.Retailer.NotFound].Value;
            return RedirectToAction(nameof(Index));
        }
        catch (RetailerCurrencyLostException)
        {
            TempData[TempDataKeys.StatusMessageError] = _localizer[RetailerResourceKeys.Retailer.CurrencyLost].Value;
            return RedirectToAction(nameof(Details), new { model.RetailerNo });
        }
    }

    [HttpGet("validate/taxId")]
    public async Task<IActionResult> ValidateTaxId(string taxId, int? retailerNo = null)
    {
        var retailer = await _retailerRepository.FindByTaxIdAsync(taxId);
        if (retailer == null) return Json(true);
        if (retailerNo != null && retailer.RetailerNo == retailerNo) return Json(true);
        return Json(_localizer[RetailerResourceKeys.Retailer.DuplicateTaxId].Value);
    }

    [HttpGet("validate/name")]
    public async Task<IActionResult> ValidateName(string name, int? retailerNo = null)
    {
        var retailer = await _retailerRepository.FindByNameAsync(name);
        if (retailer == null) return Json(true);
        if (retailerNo != null && retailer.RetailerNo == retailerNo) return Json(true);
        return Json(_localizer[RetailerResourceKeys.Retailer.DuplicateName].Value);
    }
}
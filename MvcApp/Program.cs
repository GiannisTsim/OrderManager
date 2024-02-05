using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using OrderManager.Infrastructure.DependencyInjection;
using OrderManager.Infrastructure.SqlServer.DependencyInjection;
using OrderManager.MvcApp.Utilities;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddLocalization(options => options.ResourcesPath = "Resources");

builder.Services.AddControllersWithViews
(
    options => { options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute()); }
);

// Configure custom html generator to override validation css classnames
builder.Services.AddSingleton<IHtmlGenerator, BootstrapValidationHtmlGenerator>();

builder.Services.AddServices();
builder.Services.AddRepositories();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute
(
    name: "areas",
    pattern: "{area:exists}/{controller=Index}/{action=Index}"
);

app.MapControllerRoute
(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}"
);

app.Run();
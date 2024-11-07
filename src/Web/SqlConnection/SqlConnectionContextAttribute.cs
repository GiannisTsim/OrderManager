using Microsoft.AspNetCore.Mvc.Filters;

namespace OrderManager.Web.SqlConnection;

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
public class SqlConnectionContextAttribute : ActionFilterAttribute
{
    private readonly SqlConnectionContext _sqlConnectionContext;

    public SqlConnectionContextAttribute(string connectionStringName)
    {
        _sqlConnectionContext = new SqlConnectionContext { ConnectionStringName = connectionStringName };
    }

    public override void OnActionExecuting(ActionExecutingContext context)
    {
        SqlConnectionContext.Current = _sqlConnectionContext;
    }
}
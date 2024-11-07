namespace OrderManager.Web.SqlConnection;

public class SqlConnectionContext
{
    private static readonly AsyncLocal<SqlConnectionContext?> _current = new();

    public static SqlConnectionContext? Current
    {
        get => _current.Value;
        set => _current.Value = value;
    }

    public string? ConnectionStringName { get; init; }
}
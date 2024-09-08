namespace OrderManager.Core.Person.Exceptions.Person;

public class PersonInvalidEmailException : Exception
{
    private const string DefaultMessageTemplate = "Email '{0}' is invalid.";
    public string? Email { get; }

    public PersonInvalidEmailException(string? email, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, email))
    {
        Email = email;
    }

    public PersonInvalidEmailException(string? email, Exception inner, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, email), inner)
    {
        Email = email;
    }
}
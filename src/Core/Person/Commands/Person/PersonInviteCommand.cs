using OrderManager.Core.Person.Exceptions.Person;

namespace OrderManager.Core.Person.Commands.Person;

public abstract record PersonInviteCommand
{
    public string Email { get; }
    public bool EmailConfirmed { get; }
    public DateTimeOffset InvitationDtm { get; }

    protected PersonInviteCommand(string? email)
    {
        Email = !string.IsNullOrWhiteSpace(email) ? email.Trim() : throw new PersonInvalidEmailException(email);
        EmailConfirmed = false;
        InvitationDtm = DateTimeOffset.Now;
    }
}
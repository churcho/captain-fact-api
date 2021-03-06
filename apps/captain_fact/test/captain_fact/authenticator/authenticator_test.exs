defmodule CaptainFact.AuthenticatorTest do
  use CaptainFact.DataCase
  use ExUnitProperties

  alias CaptainFact.Authenticator

  describe "Identity" do
    test "can login" do
      password = "password458"
      user = insert_user_with_custom_password(password)
      authenticated_user = Authenticator.get_user_for_email_password(user.email, password)

      assert user.id == authenticated_user.id
    end

    property "password must be correct" do
      password =
        "IfPropertyTestingFailsWithThisString,itIsNotABugButAVeryVeryRareCase,iMeanAlmostImpossible!!!"

      user = insert_user_with_custom_password(password)

      check all password <- binary(), max_runs: 3 do
        assert is_nil(Authenticator.get_user_for_email_password(user.email, password))
      end
    end
  end

  defp insert_user_with_custom_password(password) do
    insert(:user, %{encrypted_password: Bcrypt.hash_pwd_salt(password)})
  end
end

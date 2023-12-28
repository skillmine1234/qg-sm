class SmPaymentPolicy < DataAccessPolicy
  def steps?
    show?
  end
end
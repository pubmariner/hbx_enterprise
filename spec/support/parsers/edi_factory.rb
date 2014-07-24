module EdiFactory
  def member_id_ref_segment(member_id)
    [0, "17", member_id]
  end

  def carrier_member_id_ref_segment(member_id)
    [0, "23", member_id]
  end
end

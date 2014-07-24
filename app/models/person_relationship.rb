class PersonRelationship
  include Mongoid::Document
  include Mongoid::Timestamps

  MALE_RELATIONSHIPS_LIST   = %W[father grandfather grandson uncle nephew adopted\ child stepparent
                              foster\ child son-in-law brother-in-law father-in-law brother ward
                              stepson child sponsored\ dependent dependent\ of\ a\ minor\ dependent
                              guardian court\ appointed\ guardian collateral\ dependent life\ partner]

  FEMALE_RELATIONSHIPS_LIST = %W[mother grandmother granddaughter aunt niece adopted\ child stepparent
                              foster\ child daughter-in-law sister-in-law mother-in-law sister ward
                              stepdaughter child sponsored\ dependent dependent\ of\ a\ minor\ dependent
                              guardian court\ appointed\ guardian collateral\ dependent life\ partner]

  SYMMETRICAL_RELATIONSHIPS_LIST = %W[head\ of\ household spouse ex-spouse cousin ward trustee annuitant other\ relationship other\ relative self]

  ALL_RELATIONSHIPS_LIST    =  SYMMETRICAL_RELATIONSHIPS_LIST | MALE_RELATIONSHIPS_LIST | FEMALE_RELATIONSHIPS_LIST

  # Relationships are defined using RDF-style Subject -> Predicate -> Object
  # Subject is 'head of household' by convention
  field :subject_person, type: Moped::BSON::ObjectId
  field :relationship_kind, type: String
  field :object_person, type: Moped::BSON::ObjectId

	validates_presence_of :subject_person, :relationship_kind, :object_person
	validates_inclusion_of :relationship_kind, in: ALL_RELATIONSHIPS_LIST

  embedded_in :household, :inverse_of => :person_relationships
  embedded_in :application_group, :inverse_of => :person_relationships

end

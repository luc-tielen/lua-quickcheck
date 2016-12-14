
--- Helper module containing enumeration of all possible results after
--  evaluating a property.
-- @module lqc.property_result

--- List of possible results after executing property
-- @table result_enum
-- @field SUCCESS property succeeded
-- @field FAILURE property failed
-- @field SKIPPED property skipped (implies predicate not met)
return {
  SUCCESS = 1,
  FAILURE = 2,
  SKIPPED = 3
}


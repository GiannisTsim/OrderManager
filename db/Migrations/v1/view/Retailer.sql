-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer_V stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE VIEW Retailer_V AS
SELECT RetailerNo,
       VatId,
       Name,
       UpdatedDtm,
       IsObsolete,
       (
           SELECT COUNT(*)
           FROM RetailerBranch
           WHERE RetailerNo = Retailer.RetailerNo
       ) AS BranchCount
FROM Retailer;
-- rollback DROP VIEW Retailer_V;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch_V stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE VIEW RetailerBranch_V AS
SELECT RB.RetailerNo,
       BranchNo,
       RB.Name,
       R.UpdatedDtm AS UpdatedDtm,
       CASE WHEN RB.IsObsolete = 1 OR R.IsObsolete = 1 THEN 1
            ELSE 0
       END          AS IsObsolete,
       (
           SELECT COUNT(*)
           FROM ItineraryStop
           WHERE RetailerNo = RB.RetailerNo
             AND BranchNo = RB.BranchNo
       )            AS WeeklyDeliveryCount,
       1            AS NextDeliveryDtm
FROM RetailerBranch RB
INNER JOIN Retailer R
ON RB.RetailerNo = R.RetailerNo;
-- rollback DROP VIEW RetailerBranch_V;


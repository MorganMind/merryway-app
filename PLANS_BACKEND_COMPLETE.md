# Plans (Planner Mode) - Complete Backend Implementation Guide

## 📋 Overview

This guide covers the complete backend implementation for Plans (Planner Mode) - a collaborative planning feature with AI assistance from Morgan.

**Status:** ✅ Database schema created, models defined  
**Next:** Run SQL migration, implement services & views

---

## 🗄️ Step 1: Run Database Migration

### In Supabase SQL Editor:

Run `supabase_plans_schema.sql` to create all tables, indexes, RLS policies, and views.

**Tables created:**
- `plans` - Main planning threads
- `plan_members` - Participants in a plan
- `plan_messages` - Chat messages
- `plan_proposals` - Proposed activities/ideas
- `plan_votes` - Votes on proposals (+1/0/-1)
- `plan_constraints` - Planning constraints
- `plan_decisions` - Final decisions
- `plan_itineraries` - Multi-stop itineraries
- `plan_households` - Cross-household extension
- `plan_invites` - Invite links for cross-household

---

## 🐍 Step 2: Backend Services

### File: `family/services/plans_service.py`

```python
"""
Plans Service - Core business logic for planning
"""
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
from ..models.plans import (
    Plan, PlanMember, PlanMessage, PlanProposal, PlanVote,
    PlanConstraint, PlanDecision, PlanItinerary,
    CreatePlanRequest, PlanSummary, ProposalWithVotes,
    FeasibilityStatus, ProposalFeasibility, FeasibilityReason
)
from common.supabase.supabase_client import get_admin_client
from common.logger.logger_service import get_logger

logger = get_logger()


class PlansService:
    """Service for managing plans"""
    
    @staticmethod
    async def create_plan(request: CreatePlanRequest) -> Plan:
        """Create a new plan"""
        supabase = get_admin_client()
        
        # Create plan
        plan_data = {
            "household_id": request.household_id,
            "title": request.title,
            "status": "active"
        }
        
        plan_result = supabase.table("plans").insert(plan_data).execute()
        plan = Plan(**plan_result.data[0])
        
        # Add members
        if request.member_ids:
            for member_id in request.member_ids:
                # Determine if member is adult
                member_result = supabase.table("family_members")\
                    .select("age")\
                    .eq("id", member_id)\
                    .execute()
                
                if member_result.data:
                    age = member_result.data[0].get("age", 0)
                    role = "adult" if age >= 18 else "kid"
                    can_decide = age >= 18
                else:
                    role = "kid"
                    can_decide = False
                
                member_data = {
                    "plan_id": plan.id,
                    "member_id": member_id,
                    "role": role,
                    "can_decide": can_decide
                }
                
                supabase.table("plan_members").insert(member_data).execute()
        
        # Add seed proposal if provided
        if request.seed_proposal:
            proposal_data = {
                "plan_id": plan.id,
                **request.seed_proposal
            }
            supabase.table("plan_proposals").insert(proposal_data).execute()
        
        logger.info(f"Created plan {plan.id} for household {request.household_id}")
        return plan
    
    @staticmethod
    async def get_plan_summaries(household_id: str, status: Optional[str] = None, search: Optional[str] = None, limit: int = 20) -> List[PlanSummary]:
        """Get plan summaries for a household"""
        supabase = get_admin_client()
        
        # Build query
        query = supabase.table("plan_summaries")\
            .select("*")\
            .eq("household_id", household_id)\
            .order("updated_at", desc=True)\
            .limit(limit)
        
        if status:
            query = query.eq("status", status)
        
        if search:
            query = query.ilike("title", f"%{search}%")
        
        result = query.execute()
        
        # Transform to PlanSummary objects
        summaries = []
        for row in result.data or []:
            # Get member facepile
            members_data = row.get("members") or []
            facepile = []
            
            for member_data in members_data:
                member_id = member_data.get("member_id")
                member_result = supabase.table("family_members")\
                    .select("name, photo_url")\
                    .eq("id", member_id)\
                    .execute()
                
                if member_result.data:
                    m = member_result.data[0]
                    facepile.append({
                        "member_id": member_id,
                        "name": m.get("name", ""),
                        "photo_url": m.get("photo_url")
                    })
            
            last_msg = row.get("last_message") or {}
            
            summary = PlanSummary(
                id=row["id"],
                household_id=row["household_id"],
                title=row["title"],
                status=row["status"],
                member_facepile=facepile,
                last_message_snippet=last_msg.get("body", "")[:100] if last_msg.get("body") else None,
                last_message_author=last_msg.get("author_type") if last_msg else None,
                proposal_count=row.get("proposal_count", 0),
                created_at=row["created_at"],
                updated_at=row["updated_at"]
            )
            summaries.append(summary)
        
        return summaries
    
    @staticmethod
    async def get_plan(plan_id: str) -> Optional[Plan]:
        """Get a plan by ID"""
        supabase = get_admin_client()
        
        result = supabase.table("plans").select("*").eq("id", plan_id).execute()
        
        if result.data:
            return Plan(**result.data[0])
        return None
    
    @staticmethod
    async def get_plan_messages(plan_id: str, limit: int = 50, before: Optional[str] = None) -> List[PlanMessage]:
        """Get messages for a plan"""
        supabase = get_admin_client()
        
        query = supabase.table("plan_messages")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .order("created_at", desc=True)\
            .limit(limit)
        
        if before:
            query = query.lt("created_at", before)
        
        result = query.execute()
        
        messages = [PlanMessage(**row) for row in reversed(result.data or [])]
        return messages
    
    @staticmethod
    async def send_message(plan_id: str, author_member_id: Optional[str], body_md: str, attachments: List = None, reply_to_id: Optional[str] = None) -> PlanMessage:
        """Send a message in a plan"""
        supabase = get_admin_client()
        
        message_data = {
            "plan_id": plan_id,
            "author_type": "morgan" if author_member_id is None else "member",
            "author_member_id": author_member_id,
            "body_md": body_md,
            "attachments": attachments or [],
            "reply_to_id": reply_to_id
        }
        
        result = supabase.table("plan_messages").insert(message_data).execute()
        return PlanMessage(**result.data[0])
    
    @staticmethod
    async def create_proposal(plan_id: str, proposal_data: Dict[str, Any]) -> PlanProposal:
        """Create a proposal"""
        supabase = get_admin_client()
        
        proposal_data["plan_id"] = plan_id
        result = supabase.table("plan_proposals").insert(proposal_data).execute()
        
        return PlanProposal(**result.data[0])
    
    @staticmethod
    async def get_proposals_with_votes(plan_id: str, voter_member_id: Optional[str] = None) -> List[ProposalWithVotes]:
        """Get proposals with vote counts"""
        supabase = get_admin_client()
        
        # Get proposals with vote summaries
        result = supabase.table("proposal_summaries")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .order("score", desc=True)\
            .execute()
        
        proposals_with_votes = []
        
        for row in result.data or []:
            # Get user's vote if provided
            user_vote = None
            if voter_member_id:
                vote_result = supabase.table("plan_votes")\
                    .select("value")\
                    .eq("proposal_id", row["id"])\
                    .eq("voter_member_id", voter_member_id)\
                    .execute()
                
                if vote_result.data:
                    user_vote = vote_result.data[0]["value"]
            
            # Get feasibility
            feasibility = await PlansService.check_proposal_feasibility(row["id"], plan_id)
            
            proposal = PlanProposal(**{k: v for k, v in row.items() if k in PlanProposal.__fields__})
            
            proposals_with_votes.append(ProposalWithVotes(
                proposal=proposal,
                upvotes=row.get("upvotes", 0),
                downvotes=row.get("downvotes", 0),
                neutral=row.get("neutral", 0),
                score=row.get("score", 0),
                user_vote=user_vote,
                feasibility=feasibility.dict() if feasibility else None
            ))
        
        return proposals_with_votes
    
    @staticmethod
    async def vote_on_proposal(proposal_id: str, voter_member_id: str, value: int) -> PlanVote:
        """Vote on a proposal (upsert)"""
        supabase = get_admin_client()
        
        vote_data = {
            "proposal_id": proposal_id,
            "voter_member_id": voter_member_id,
            "value": value
        }
        
        result = supabase.table("plan_votes")\
            .upsert(vote_data)\
            .execute()
        
        return PlanVote(**result.data[0])
    
    @staticmethod
    async def add_constraint(plan_id: str, constraint_type: str, value_json: Dict, added_by: Optional[str] = None) -> PlanConstraint:
        """Add a constraint to a plan"""
        supabase = get_admin_client()
        
        constraint_data = {
            "plan_id": plan_id,
            "type": constraint_type,
            "value_json": value_json,
            "added_by_member_id": added_by
        }
        
        result = supabase.table("plan_constraints").insert(constraint_data).execute()
        return PlanConstraint(**result.data[0])
    
    @staticmethod
    async def get_constraints(plan_id: str) -> List[PlanConstraint]:
        """Get all constraints for a plan"""
        supabase = get_admin_client()
        
        result = supabase.table("plan_constraints")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .execute()
        
        return [PlanConstraint(**row) for row in result.data or []]
    
    @staticmethod
    async def create_decision(plan_id: str, decided_by: str, proposal_id: Optional[str] = None, summary_md: str = "") -> PlanDecision:
        """Create a decision for a plan"""
        supabase = get_admin_client()
        
        decision_data = {
            "plan_id": plan_id,
            "proposal_id": proposal_id,
            "summary_md": summary_md,
            "decided_by_member_id": decided_by
        }
        
        result = supabase.table("plan_decisions").insert(decision_data).execute()
        
        # Archive the plan
        supabase.table("plans").update({"status": "archived"}).eq("id", plan_id).execute()
        
        return PlanDecision(**result.data[0])
    
    @staticmethod
    async def create_or_update_itinerary(plan_id: str, title: str, items: List[Dict], created_by: str) -> PlanItinerary:
        """Create or update itinerary"""
        supabase = get_admin_client()
        
        # Check if itinerary exists
        existing = supabase.table("plan_itineraries")\
            .select("id")\
            .eq("plan_id", plan_id)\
            .execute()
        
        itinerary_data = {
            "plan_id": plan_id,
            "title": title,
            "items_json": items,
            "created_by_member_id": created_by
        }
        
        if existing.data:
            # Update
            result = supabase.table("plan_itineraries")\
                .update(itinerary_data)\
                .eq("plan_id", plan_id)\
                .execute()
        else:
            # Insert
            result = supabase.table("plan_itineraries")\
                .insert(itinerary_data)\
                .execute()
        
        return PlanItinerary(**result.data[0])
    
    @staticmethod
    async def archive_plan(plan_id: str):
        """Archive a plan"""
        supabase = get_admin_client()
        
        supabase.table("plans").update({"status": "archived"}).eq("id", plan_id).execute()
        logger.info(f"Archived plan {plan_id}")
    
    @staticmethod
    async def reopen_plan(plan_id: str):
        """Reopen an archived plan"""
        supabase = get_admin_client()
        
        supabase.table("plans").update({"status": "active"}).eq("id", plan_id).execute()
        logger.info(f"Reopened plan {plan_id}")
    
    @staticmethod
    async def check_proposal_feasibility(proposal_id: str, plan_id: str) -> Optional[ProposalFeasibility]:
        """Check if a proposal is feasible given constraints"""
        supabase = get_admin_client()
        
        # Get proposal
        proposal_result = supabase.table("plan_proposals").select("*").eq("id", proposal_id).execute()
        if not proposal_result.data:
            return None
        
        proposal = proposal_result.data[0]
        
        # Get constraints
        constraints_result = supabase.table("plan_constraints").select("*").eq("plan_id", plan_id).execute()
        constraints = constraints_result.data or []
        
        # Check feasibility
        reasons = []
        status = FeasibilityStatus.FITS
        
        for constraint in constraints:
            constraint_type = constraint["type"]
            value = constraint["value_json"]
            
            if constraint_type == "cost_cap":
                if proposal.get("cost_band"):
                    # Simple cost band check (you'd implement proper logic)
                    max_cost = value.get("max_cost", 100)
                    proposal_cost = {"free": 0, "low": 25, "medium": 50, "high": 100}.get(proposal["cost_band"], 50)
                    
                    if proposal_cost > max_cost:
                        status = FeasibilityStatus.BLOCKED
                        reasons.append(FeasibilityReason(
                            type="over_budget",
                            message=f"Cost ({proposal['cost_band']}) exceeds budget (${max_cost})",
                            fix_suggestion="Choose a lower-cost option"
                        ))
            
            elif constraint_type == "indoor_only":
                if proposal.get("indoor_outdoor") == "outdoor":
                    status = FeasibilityStatus.BLOCKED
                    reasons.append(FeasibilityReason(
                        type="outdoor_not_allowed",
                        message="Outdoor activity but indoor-only constraint is set",
                        fix_suggestion="Switch to an indoor alternative"
                    ))
            
            elif constraint_type == "duration_cap":
                max_duration = value.get("max_duration_min", 120)
                if proposal.get("duration_min", 0) > max_duration:
                    status = FeasibilityStatus.STRETCH
                    reasons.append(FeasibilityReason(
                        type="too_long",
                        message=f"Duration ({proposal['duration_min']}min) exceeds limit ({max_duration}min)",
                        fix_suggestion="Shorten the activity or adjust time constraint"
                    ))
        
        # Calculate score (0.0 to 1.0)
        if status == FeasibilityStatus.FITS:
            score = 1.0
        elif status == FeasibilityStatus.STRETCH:
            score = 0.5
        else:
            score = 0.0
        
        return ProposalFeasibility(
            proposal_id=proposal_id,
            status=status,
            reasons=reasons,
            score=score
        )
```

(Continued in next file...)


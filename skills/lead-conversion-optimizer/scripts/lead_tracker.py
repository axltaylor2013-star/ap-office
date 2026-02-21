#!/usr/bin/env python3
"""
Lead Conversion Tracker for Kermicle Media AI Business
Tracks leads through the conversion funnel and calculates key metrics
"""

import json
import os
from datetime import datetime, timedelta
from typing import Dict, List, Optional

class LeadTracker:
    def __init__(self, data_file: str = "leads_pipeline.json"):
        self.data_file = data_file
        self.leads = self.load_leads()
        
    def load_leads(self) -> List[Dict]:
        """Load existing leads from JSON file"""
        if os.path.exists(self.data_file):
            with open(self.data_file, 'r') as f:
                return json.load(f)
        return []
    
    def save_leads(self):
        """Save leads to JSON file"""
        with open(self.data_file, 'w') as f:
            json.dump(self.leads, f, indent=2, default=str)
    
    def add_lead(self, name: str, email: str, phone: str, source: str, 
                 inquiry_type: str, company: str = "", notes: str = "") -> str:
        """Add new lead to pipeline"""
        lead_id = f"LEAD_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        lead = {
            "id": lead_id,
            "name": name,
            "email": email, 
            "phone": phone,
            "company": company,
            "source": source,  # website, referral, social, networking
            "inquiry_type": inquiry_type,  # consultation, pricing, specific_service
            "stage": "new",  # new, qualified, consultation, proposal, closed_won, closed_lost
            "created_date": datetime.now().isoformat(),
            "last_contact": datetime.now().isoformat(),
            "notes": notes,
            "activities": [],
            "deal_size": 0,
            "expected_close": None
        }
        
        self.leads.append(lead)
        self.save_leads()
        return lead_id
    
    def update_stage(self, lead_id: str, new_stage: str, notes: str = ""):
        """Move lead to new stage in pipeline"""
        lead = self.get_lead(lead_id)
        if lead:
            old_stage = lead["stage"]
            lead["stage"] = new_stage
            lead["last_contact"] = datetime.now().isoformat()
            
            activity = {
                "date": datetime.now().isoformat(),
                "type": "stage_change",
                "description": f"Moved from {old_stage} to {new_stage}",
                "notes": notes
            }
            lead["activities"].append(activity)
            self.save_leads()
            return True
        return False
    
    def add_activity(self, lead_id: str, activity_type: str, description: str, notes: str = ""):
        """Add activity to lead record"""
        lead = self.get_lead(lead_id)
        if lead:
            activity = {
                "date": datetime.now().isoformat(),
                "type": activity_type,  # call, email, meeting, proposal_sent
                "description": description,
                "notes": notes
            }
            lead["activities"].append(activity)
            lead["last_contact"] = datetime.now().isoformat()
            self.save_leads()
            return True
        return False
    
    def get_lead(self, lead_id: str) -> Optional[Dict]:
        """Get lead by ID"""
        for lead in self.leads:
            if lead["id"] == lead_id:
                return lead
        return None
    
    def get_conversion_rates(self) -> Dict:
        """Calculate conversion rates by stage"""
        if not self.leads:
            return {}
        
        stages = ["new", "qualified", "consultation", "proposal", "closed_won"]
        stage_counts = {stage: 0 for stage in stages}
        
        for lead in self.leads:
            if lead["stage"] in stage_counts:
                stage_counts[lead["stage"]] += 1
        
        # Add closed_lost to total leads count
        total_leads = len(self.leads)
        
        conversion_rates = {}
        if total_leads > 0:
            conversion_rates["lead_to_qualified"] = (stage_counts["qualified"] + 
                                                   stage_counts["consultation"] + 
                                                   stage_counts["proposal"] + 
                                                   stage_counts["closed_won"]) / total_leads * 100
            
            qualified_total = (stage_counts["qualified"] + stage_counts["consultation"] + 
                             stage_counts["proposal"] + stage_counts["closed_won"])
            
            if qualified_total > 0:
                conversion_rates["qualified_to_consultation"] = (stage_counts["consultation"] + 
                                                               stage_counts["proposal"] + 
                                                               stage_counts["closed_won"]) / qualified_total * 100
            
            consultation_total = stage_counts["consultation"] + stage_counts["proposal"] + stage_counts["closed_won"]
            if consultation_total > 0:
                conversion_rates["consultation_to_proposal"] = (stage_counts["proposal"] + 
                                                              stage_counts["closed_won"]) / consultation_total * 100
            
            proposal_total = stage_counts["proposal"] + stage_counts["closed_won"]
            if proposal_total > 0:
                conversion_rates["proposal_to_close"] = stage_counts["closed_won"] / proposal_total * 100
        
        return conversion_rates
    
    def get_source_performance(self) -> Dict:
        """Analyze lead performance by source"""
        source_stats = {}
        
        for lead in self.leads:
            source = lead["source"]
            if source not in source_stats:
                source_stats[source] = {
                    "total_leads": 0,
                    "qualified": 0,
                    "closed_won": 0,
                    "total_revenue": 0
                }
            
            source_stats[source]["total_leads"] += 1
            
            if lead["stage"] in ["qualified", "consultation", "proposal", "closed_won"]:
                source_stats[source]["qualified"] += 1
            
            if lead["stage"] == "closed_won":
                source_stats[source]["closed_won"] += 1
                source_stats[source]["total_revenue"] += lead.get("deal_size", 0)
        
        # Calculate rates
        for source, stats in source_stats.items():
            if stats["total_leads"] > 0:
                stats["qualification_rate"] = stats["qualified"] / stats["total_leads"] * 100
                stats["close_rate"] = stats["closed_won"] / stats["total_leads"] * 100
            if stats["closed_won"] > 0:
                stats["avg_deal_size"] = stats["total_revenue"] / stats["closed_won"]
        
        return source_stats
    
    def generate_report(self) -> str:
        """Generate comprehensive pipeline report"""
        total_leads = len(self.leads)
        conversion_rates = self.get_conversion_rates()
        source_performance = self.get_source_performance()
        
        report = f"""
=== KERMICLE MEDIA LEAD CONVERSION REPORT ===
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}

PIPELINE OVERVIEW:
- Total Leads: {total_leads}
- Active Pipeline: {len([l for l in self.leads if l['stage'] not in ['closed_won', 'closed_lost']])}
- Closed Won: {len([l for l in self.leads if l['stage'] == 'closed_won'])}
- Closed Lost: {len([l for l in self.leads if l['stage'] == 'closed_lost'])}

CONVERSION RATES:
"""
        
        for rate_name, rate_value in conversion_rates.items():
            report += f"- {rate_name.replace('_', ' ').title()}: {rate_value:.1f}%\n"
        
        report += "\nSOURCE PERFORMANCE:\n"
        for source, stats in source_performance.items():
            report += f"\n{source.upper()}:\n"
            report += f"  - Total Leads: {stats['total_leads']}\n"
            report += f"  - Qualification Rate: {stats.get('qualification_rate', 0):.1f}%\n"
            report += f"  - Close Rate: {stats.get('close_rate', 0):.1f}%\n"
            report += f"  - Avg Deal Size: ${stats.get('avg_deal_size', 0):,.0f}\n"
            report += f"  - Total Revenue: ${stats['total_revenue']:,.0f}\n"
        
        return report

def main():
    """Command line interface for lead tracker"""
    import sys
    
    tracker = LeadTracker()
    
    if len(sys.argv) < 2:
        print("Usage: python lead_tracker.py <command> [args...]")
        print("Commands: add, update_stage, activity, report")
        return
    
    command = sys.argv[1]
    
    if command == "add":
        if len(sys.argv) < 7:
            print("Usage: add <name> <email> <phone> <source> <inquiry_type> [company] [notes]")
            return
        
        name, email, phone, source, inquiry_type = sys.argv[2:7]
        company = sys.argv[7] if len(sys.argv) > 7 else ""
        notes = sys.argv[8] if len(sys.argv) > 8 else ""
        
        lead_id = tracker.add_lead(name, email, phone, source, inquiry_type, company, notes)
        print(f"Added lead: {lead_id}")
    
    elif command == "update_stage":
        if len(sys.argv) < 4:
            print("Usage: update_stage <lead_id> <new_stage> [notes]")
            return
        
        lead_id, new_stage = sys.argv[2:4]
        notes = sys.argv[4] if len(sys.argv) > 4 else ""
        
        if tracker.update_stage(lead_id, new_stage, notes):
            print(f"Updated {lead_id} to {new_stage}")
        else:
            print(f"Lead {lead_id} not found")
    
    elif command == "activity":
        if len(sys.argv) < 5:
            print("Usage: activity <lead_id> <type> <description> [notes]")
            return
        
        lead_id, activity_type, description = sys.argv[2:5]
        notes = sys.argv[5] if len(sys.argv) > 5 else ""
        
        if tracker.add_activity(lead_id, activity_type, description, notes):
            print(f"Added activity to {lead_id}")
        else:
            print(f"Lead {lead_id} not found")
    
    elif command == "report":
        print(tracker.generate_report())
    
    else:
        print(f"Unknown command: {command}")

if __name__ == "__main__":
    main()
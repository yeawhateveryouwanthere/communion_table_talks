import json

# Read all JSON files
with open('presentations_brief.json', 'r') as f:
    brief = json.load(f)
with open('presentations_medium_1.json', 'r') as f:
    medium1 = json.load(f)
with open('presentations_medium_2.json', 'r') as f:
    medium2 = json.load(f)
with open('presentations_substantive_1.json', 'r') as f:
    sub1 = json.load(f)
with open('presentations_substantive_2.json', 'r') as f:
    sub2 = json.load(f)

# Read the template
with open('upload_all.html', 'r') as f:
    template = f.read()

# Replace placeholders with actual data
template = template.replace('BRIEF_DATA', json.dumps(brief))
template = template.replace('MEDIUM1_DATA', json.dumps(medium1))
template = template.replace('MEDIUM2_DATA', json.dumps(medium2))
template = template.replace('SUBSTANTIVE1_DATA', json.dumps(sub1))
template = template.replace('SUBSTANTIVE2_DATA', json.dumps(sub2))

with open('upload_presentations.html', 'w') as f:
    f.write(template)

print(f"Built upload page with {len(brief)} brief, {len(medium1)+len(medium2)} medium, {len(sub1)+len(sub2)} substantive = {len(brief)+len(medium1)+len(medium2)+len(sub1)+len(sub2)} total")

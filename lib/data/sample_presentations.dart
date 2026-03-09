import '../models/presentation.dart';

/// Sample presentations for testing and development.
///
/// These will be replaced by Firestore data once Firebase is set up.
final List<Presentation> samplePresentations = [
  Presentation(
    id: '1',
    title: 'Remembering the Cross',
    scripturePassage: '1 Corinthians 11:23-26',
    bodyText: '''
<p>On the night He was betrayed, Jesus took bread, and when He had given thanks, He broke it and said, <em>"This is my body, which is for you; do this in remembrance of me."</em></p>

<p>Every week, we gather around this table not out of ritual or routine, but because our Lord asked us to remember. And what are we remembering? We are remembering the most selfless act of love the world has ever known.</p>

<p>As you take the bread, remember His body — broken for you. As you take the cup, remember His blood — poured out for the forgiveness of your sins. Let us eat and drink together, proclaiming the Lord's death until He comes.</p>
''',
    summary:
        'A brief reflection on the institution of the Lord\'s Supper, focusing on Jesus\' words on the night of His betrayal and what it means to remember Him each Lord\'s Day.',
    topicTags: ['remembrance', 'cross', 'sacrifice', 'institution'],
    length: PresentationLength.brief,
    suggestedHymns: [
      'When I Survey the Wondrous Cross',
      'In Remembrance',
      'At the Cross',
    ],
    datePublished: DateTime(2026, 3, 1),
  ),
  Presentation(
    id: '2',
    title: 'The Cup of the New Covenant',
    scripturePassage: 'Luke 22:19-20; Jeremiah 31:31-34',
    bodyText: '''
<p>When Jesus lifted the cup that night in the upper room, He said something remarkable: <em>"This cup is the new covenant in my blood, which is poured out for you."</em></p>

<p>To understand the weight of those words, we need to go back to Jeremiah. For centuries, God's people lived under a covenant written on tablets of stone. But through Jeremiah, God promised something new — a covenant written not on stone, but on human hearts.</p>

<p><strong>What makes this covenant new?</strong> Under the old covenant, the blood of bulls and goats was offered year after year, but it could never truly take away sin. Under the new covenant, the blood of Christ was offered once for all. His sacrifice doesn't need to be repeated — it is finished, complete, and sufficient.</p>

<p>But there's more to this promise. God said through Jeremiah, <em>"I will forgive their wickedness and will remember their sins no more."</em> Think about that — the Creator of the universe chooses not to remember our sins. Not because He can't recall them, but because through Christ's blood, they have been fully dealt with.</p>

<p>As we share this cup today, we are participating in that new covenant. We are holding in our hands the symbol of a promise kept — God's promise to forgive, to restore, and to make us His people. Let us drink with gratitude and with hope.</p>
''',
    summary:
        'An exploration of how Jesus\' words at the Last Supper connect to Jeremiah\'s prophecy of a new covenant, and what it means that Christ\'s blood established that covenant for us.',
    topicTags: ['new covenant', 'blood', 'forgiveness', 'prophecy', 'Jeremiah'],
    length: PresentationLength.medium,
    suggestedHymns: [
      'Nothing but the Blood',
      'There Is a Fountain',
      'Blest Be the Tie That Binds',
    ],
    datePublished: DateTime(2026, 3, 1),
  ),
  Presentation(
    id: '3',
    title: 'Until He Comes: Living Between the Table and the Return',
    scripturePassage: '1 Corinthians 11:23-26; Revelation 19:6-9',
    bodyText: '''
<p>Paul writes that as often as we eat this bread and drink this cup, we <em>"proclaim the Lord's death until He comes."</em> That small phrase — <strong>until He comes</strong> — transforms the Lord's Supper from an act of looking back into an act of looking forward.</p>

<p>The Lord's Supper sits at the intersection of past, present, and future. We look back to the cross, where Jesus gave His life for us. We look inward at our present relationship with God and with one another. And we look forward to the day when Christ will return and gather His people to Himself.</p>

<p><strong>Looking Back: The Cross</strong></p>
<p>Jesus said, <em>"Do this in remembrance of me."</em> The word "remembrance" in the original Greek carries more weight than our English word suggests. It's not merely recalling a fact — it's an active, participatory remembering. When we eat the bread and drink the cup, we are brought into the reality of what happened on Calvary. We are there, at the foot of the cross, witnessing love poured out.</p>

<p><strong>Looking Inward: Self-Examination</strong></p>
<p>Paul warns in this same passage that a person should examine themselves before eating and drinking. This is not meant to make us feel unworthy — if worthiness were the requirement, none of us could approach. Rather, it's an invitation to honesty. Are we holding grudges? Have we neglected our relationship with God? Are we going through the motions without engaging our hearts? The table calls us back to sincerity.</p>

<p><strong>Looking Forward: The Coming Feast</strong></p>
<p>In Revelation 19, John describes a glorious scene: the marriage supper of the Lamb. <em>"Blessed are those who are invited to the marriage supper of the Lamb!"</em> Every Lord's Day, as we share this simple meal of bread and fruit of the vine, we are rehearsing for that great feast. We are reminding ourselves — and proclaiming to the world — that this is not all there is. Jesus is coming back, and when He does, we will sit at His table in glory.</p>

<p><strong>Living in the Meantime</strong></p>
<p>So what does it mean to live "until He comes"? It means we live as people of hope. We are not a people defined by the brokenness of this world but by the promise of the world to come. Every Sunday, the Lord's Supper reorients us. It pulls us out of the busyness and distraction of the week and sets our eyes on what matters most: Jesus died, Jesus lives, and Jesus is coming again.</p>

<p>As you take the bread and the cup this morning, hold all three of these realities in your heart. Remember what He did. Examine who you are today. And look forward with joy to the day when we will see Him face to face.</p>
''',
    summary:
        'A comprehensive exploration of the three dimensions of the Lord\'s Supper — looking back to the cross, looking inward through self-examination, and looking forward to Christ\'s return and the marriage supper of the Lamb.',
    topicTags: [
      'second coming',
      'remembrance',
      'self-examination',
      'hope',
      'marriage supper',
      'Revelation',
    ],
    length: PresentationLength.substantive,
    suggestedHymns: [
      'Christ Returneth',
      'When I Survey the Wondrous Cross',
      'The Lord\'s Supper',
      'Jesus Is Coming Soon',
    ],
    datePublished: DateTime(2026, 3, 1),
  ),
];

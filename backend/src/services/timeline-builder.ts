export interface TimelineEntry {
  stage: string;
  timestamp: string;
  note?: string;
  actorRole?: string;
}

export function buildDefaultTimeline(createdAt: Date = new Date()): TimelineEntry[] {
  return [
    {
      stage: 'Lot Created',
      timestamp: createdAt.toISOString(),
      note: 'Material photographed, weighed and registered offline/online with unique Lot ID.',
      actorRole: 'collector'
    },
    {
      stage: 'Price Estimated',
      timestamp: new Date(createdAt.getTime() + 1000 * 30).toISOString(),
      note: 'AI categorization completed; estimated value range calculated.',
      actorRole: 'system'
    }
  ];
}

export function appendTimelineStage(
  currentTimelineJson: string,
  stage:
    | 'Recycler Matched'
    | 'Offer Accepted'
    | 'Material Handed Over'
    | 'Recycler Confirmed'
    | 'Payment Completed',
  note?: string,
  actorRole?: string
): string {
  let list: TimelineEntry[] = [];
  try {
    list = JSON.parse(currentTimelineJson);
  } catch {
    list = buildDefaultTimeline();
  }

  // Avoid duplicate stage entries
  if (!list.some((item) => item.stage === stage)) {
    list.push({
      stage,
      timestamp: new Date().toISOString(),
      note: note || `State transitioned to ${stage}`,
      actorRole: actorRole || 'system'
    });
  }

  return JSON.stringify(list);
}

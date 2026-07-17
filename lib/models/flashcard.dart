class Flashcard {
  final String id;
  final String topic;
  final String title;
  final List<String> points;
  final String subject;
  final String pageRef;

  const Flashcard({
    required this.id,
    required this.topic,
    required this.title,
    required this.points,
    required this.subject,
    required this.pageRef,
  });
}

final List<Flashcard> dummyFlashcards = [
  Flashcard(
    id: '1',
    topic: 'Normalization',
    title: 'Normal Forms (1NF–3NF)',
    subject: 'DBMS',
    pageRef: 'pg 4–9',
    points: [
      '1NF: all values must be atomic, no repeating groups',
      '2NF: no partial dependency on a composite key',
      '3NF: no transitive dependency between non-key columns',
    ],
  ),
  Flashcard(
    id: '2',
    topic: 'Keys',
    title: 'Types of Keys',
    subject: 'DBMS',
    pageRef: 'pg 11–13',
    points: [
      'Primary key: uniquely identifies each row',
      'Foreign key: links to primary key of another table',
      'Candidate key: any column that could be a primary key',
      'Composite key: two or more columns combined as key',
    ],
  ),
  Flashcard(
    id: '3',
    topic: 'Scheduling',
    title: 'CPU Scheduling Algorithms',
    subject: 'OS',
    pageRef: 'pg 3–7',
    points: [
      'FCFS: simple, non-preemptive, causes convoy effect',
      'SJF: shortest job first, optimal average wait time',
      'Round Robin: preemptive, fixed time quantum per process',
    ],
  ),
  Flashcard(
    id: '4',
    topic: 'Integration',
    title: 'Integration Techniques',
    subject: 'Maths',
    pageRef: 'pg 2–6',
    points: [
      'Substitution: replace variable to simplify integral',
      'By parts: ∫u dv = uv − ∫v du',
      'Partial fractions: split rational functions into simpler ones',
    ],
  ),
];
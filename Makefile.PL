use ExtUtils::MakeMaker;



WriteMakefile(

	'PREREQ_PM' => { 
		'namespace::autoclean' => '0',
		'Moose' => '0',
		'Math::SMA' => '0',
		'Math::EWMA' => '0',
	},
	'TEST_REQUIRES' => {
		'Test::Class::Load' => '0',
		'Test::Class' => '0',
		'Test::Most' => '0',
		'Test::MockObject::Extends' => '0',
	},
	'LICENSE' => 'perl_5',
	'META_MERGE'        => {
		'resources' => {
			'repository'  =>  'https://github.com/smith153/BitTrader',
			},
		},
);


<?php
/*
** Copyright (C) 2001-2026 Zabbix SIA
**
** This program is free software: you can redistribute it and/or modify it under the terms of
** the GNU Affero General Public License as published by the Free Software Foundation, version 3.
**
** This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
** without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU Affero General Public License for more details.
**
** You should have received a copy of the GNU Affero General Public License along with this program.
** If not, see <https://www.gnu.org/licenses/>.
**/


use PHPUnit\Framework\TestCase;

class CTriggerGeneralHelperTest extends TestCase
{

	/**
	 * An array of trigger functions and parsed results.
	 */
	public static function dataProvider()
	{
		return [
			[
				'func(/host/item)',
				'host',
				'Advantal server',
				'func(/Advantal server/item)'
			],
			[
				'5 + func(/host/item) <> 0 or {$MACRO: "context"} or {#MACRO} or {TRIGGER.VALUE} or' .
					' func(/host/item) or func(/host2/item2)',
				'host',
				'Advantal server',
				'5 + func(/Advantal server/item) <> 0 or {$MACRO: "context"} or {#MACRO} or {TRIGGER.VALUE} or' .
					' func(/Advantal server/item) or func(/host2/item2)'
			],
			[
				'5 + func(/host/item) <> 0 or {$MACRO: "context"} or' .
					' {{#MACRO}.regsub("^([0-9]+)", "{#MACRO}: \1")} or {TRIGGER.VALUE} or' .
					' func(/host/item) or func(/host2/item2)',
				'host',
				'Advantal server',
				'5 + func(/Advantal server/item) <> 0 or {$MACRO: "context"} or' .
					' {{#MACRO}.regsub("^([0-9]+)", "{#MACRO}: \1")} or {TRIGGER.VALUE} or' .
					' func(/Advantal server/item) or func(/host2/item2)'
			],
			[
				'func(/host/item) or {{#M}.regsub("func(/host/item)", "\1")}',
				'host',
				'Advantal server',
				'func(/Advantal server/item) or {{#M}.regsub("func(/host/item)", "\1")}'
			],
			[
				'5 + func(/Advantal server/item) <> 0 or func(/Advantal server/item) or func(/host2/item2)',
				'Advantal server',
				'host',
				'5 + func(/host/item) <> 0 or func(/host/item) or func(/host2/item2)'
			],
			[
				'min(func(/host/item), func(/host/item), "func(/host/item)") = "func(/host/item)"',
				'host',
				'Advantal server',
				'min(func(/Advantal server/item), func(/Advantal server/item), "func(/host/item)") = "func(/host/item)"'
			]
		];
	}

	/**
	 * @dataProvider dataProvider
	 *
	 * @param string $source
	 * @param string  $expected
	 */
	public function testExpressionWithReplacedHost($source, $src_host, $dst_host, $expected)
	{
		$this->assertSame(
			$expected,
			CTriggerGeneralHelper::getExpressionWithReplacedHost($source, $src_host, $dst_host)
		);
	}
}

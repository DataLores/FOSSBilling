<?php
/**
 * FOSSBilling
 *
 * @copyright FOSSBilling (https://www.fossbilling.org)
 * @license   Apache-2.0
 *
 * This file may contain code previously used in the BoxBilling project.
 * Copyright BoxBilling, Inc 2011-2021
 *
 * This source file is subject to the Apache-2.0 License that is bundled
 * with this source code in the file LICENSE
 */


class Box_DbLoggedPDOStatement extends PDOStatement
{
    public function execute ($input_parameters = null): bool
    {
        error_log($this->queryString);
        return parent::execute($input_parameters);
    }
}